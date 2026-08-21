import QtQuick
import Qt5Compat.GraphicalEffects

// Logotipo (wordmark) oficial do provedor em SVG. Os arquivos usam
// fill="currentColor" (preto fixo fora de um contexto CSS), então
// recolorimos via ColorOverlay usando apenas o alfa do desenho — assim ele
// se adapta ao tema claro/escuro. Cai para o nome em Noto Serif se o
// arquivo ainda não tiver sido baixado.
Item {
    id: root

    property var provider
    property real size: 20
    property color color: "#1f2937"

    implicitHeight: size
    implicitWidth: img.status === Image.Ready ? img.width : fallbackText.implicitWidth

    Image {
        id: img
        anchors.verticalCenter: parent.verticalCenter
        height: root.size
        width: implicitHeight > 0 ? implicitWidth * (height / implicitHeight) : 0
        fillMode: Image.PreserveAspectFit
        source: root.provider.wordmark
        sourceSize.height: root.size * 3
        visible: false
        cache: true
    }

    ColorOverlay {
        anchors.verticalCenter: parent.verticalCenter
        width: img.width
        height: img.height
        source: img
        color: root.color
        visible: img.status === Image.Ready
    }

    Text {
        id: fallbackText
        anchors.verticalCenter: parent.verticalCenter
        visible: img.status !== Image.Ready
        text: root.provider.name
        font.family: "Noto Serif"
        font.bold: true
        font.pixelSize: root.size * 0.85
        color: root.color
    }
}
