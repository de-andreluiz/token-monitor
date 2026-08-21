import QtQuick

// Ícone de provedor: usa o SVG em contents/images/ (campo "icon" de Providers.js)
// quando disponível e cai automaticamente para o glifo emoji enquanto o arquivo não existir.
Item {
    id: root

    property var provider
    property real size: 20

    implicitWidth: size
    implicitHeight: size

    Image {
        id: img
        anchors.fill: parent
        source: root.provider.icon
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        fillMode: Image.PreserveAspectFit
        visible: status === Image.Ready
        cache: true
    }

    Text {
        anchors.fill: parent
        visible: img.status !== Image.Ready
        text: root.provider.glyph
        font.pixelSize: root.size * 0.85
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
