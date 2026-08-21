import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Roda de cores HSV (matiz no ângulo, saturação no raio) + slider de brilho,
// desenhada em Canvas e com um seletor arrastável — equivalente à roda de
// cor de fundo da tela "Configurar widget" do app Android de referência,
// mas permitindo qualquer cor (incluindo pretos, cinzas e tons escurecidos).
ColumnLayout {
    id: wheel

    property color color: "#ffffff"
    signal colorPicked(color newColor)

    spacing: 10

    // Evita realimentar o valor computado localmente de volta pro binding
    // externo "color" enquanto o usuário ainda está arrastando.
    property real hue: 0
    property real saturation: 0
    property real value: 1

    function setFromColor(c) {
        wheel.hue = c.hsvHue < 0 ? 0 : c.hsvHue; // cor acromática: ancora o matiz em 0
        wheel.saturation = c.hsvSaturation;
        wheel.value = c.hsvValue;
        positionSelector();
        canvas.requestPaint();
    }

    function positionSelector() {
        var angle = wheel.hue * 2 * Math.PI;
        var r = wheel.saturation * radiusPx;
        selector.x = centerPx.x + Math.cos(angle) * r - selector.width / 2;
        selector.y = centerPx.y + Math.sin(angle) * r - selector.height / 2;
    }

    function emitPicked() {
        wheel.colorPicked(Qt.hsva(wheel.hue, wheel.saturation, wheel.value, 1.0));
    }

    onColorChanged: setFromColor(color)
    Component.onCompleted: setFromColor(color)

    Item {
        id: wheelArea
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 220
        Layout.preferredHeight: 220

        readonly property real radiusPx: Math.min(width, height) / 2
        readonly property point centerPx: Qt.point(width / 2, height / 2)

        Canvas {
            id: canvas
            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d");
                var w = width, h = height;
                var img = ctx.createImageData(w, h);
                var cx = w / 2, cy = h / 2;
                var r = wheelArea.radiusPx;

                for (var y = 0; y < h; y++) {
                    for (var x = 0; x < w; x++) {
                        var dx = x - cx;
                        var dy = y - cy;
                        var dist = Math.sqrt(dx * dx + dy * dy);
                        var idx = (y * w + x) * 4;

                        if (dist > r) {
                            img.data[idx + 3] = 0;
                            continue;
                        }

                        var hue = (Math.atan2(dy, dx) + Math.PI) / (2 * Math.PI);
                        var sat = Math.min(dist / r, 1);
                        var c = Qt.hsva(hue, sat, wheel.value, 1.0);

                        img.data[idx] = c.r * 255;
                        img.data[idx + 1] = c.g * 255;
                        img.data[idx + 2] = c.b * 255;
                        img.data[idx + 3] = 255;
                    }
                }
                ctx.putImageData(img, 0, 0);
            }
        }

        Rectangle {
            id: selector
            width: 18
            height: 18
            radius: 9
            color: wheel.color
            border.color: "#ffffff"
            border.width: 3

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.color: "#33000000"
                border.width: 1
            }
        }

        MouseArea {
            anchors.fill: parent

            function pick(mx, my) {
                var dx = mx - wheelArea.centerPx.x;
                var dy = my - wheelArea.centerPx.y;
                var dist = Math.min(Math.sqrt(dx * dx + dy * dy), wheelArea.radiusPx);
                var angle = Math.atan2(dy, dx);
                if (angle < 0) angle += 2 * Math.PI;

                wheel.hue = angle / (2 * Math.PI);
                wheel.saturation = dist / wheelArea.radiusPx;
                wheel.positionSelector();
                wheel.emitPicked();
            }

            onPressed: (mouse) => pick(mouse.x, mouse.y)
            onPositionChanged: (mouse) => { if (pressed) pick(mouse.x, mouse.y); }
        }
    }

    RowLayout {
        Layout.preferredWidth: wheelArea.width
        Layout.alignment: Qt.AlignHCenter
        spacing: 8

        Label {
            text: "☀"
            opacity: 0.6
        }

        Slider {
            id: valueSlider
            Layout.fillWidth: true
            from: 0
            to: 1
            value: wheel.value

            onMoved: {
                wheel.value = value;
                canvas.requestPaint();
                wheel.emitPicked();
            }
        }

        Label {
            text: "☀"
        }
    }
}
