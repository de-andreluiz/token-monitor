import QtQuick

// Barra de progresso customizada: trilha e preenchimento
// totalmente arredondados, com animação suave de valor.
Item {
    id: bar

    property real value: 0 // 0.0 - 1.0
    property color trackColor: "#e5e7eb"
    property color fillColor: "#2563eb"
    property real barHeight: 8

    implicitHeight: barHeight

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: bar.trackColor
    }

    Rectangle {
        id: fill
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        radius: height / 2
        color: bar.fillColor
        width: Math.max(height, parent.width * Math.min(Math.max(bar.value, 0), 1))

        Behavior on width {
            NumberAnimation { duration: 450; easing.type: Easing.OutCubic }
        }
    }
}
