import QtQuick
import QtQuick.Layouts

// Card interno reutilizável (usado para "Sessão atual" e "Limites semanais")
Rectangle {
    id: card

    property string title: ""
    property int percent: 0
    property string leftText: ""
    property string rightText: ""
    property color accentColor: "#2563eb"
    property color textColor: "#1f2937"
    property color secondaryTextColor: "#6b7280"
    property color trackColor: "#e2e5ea"

    Layout.fillWidth: true
    Layout.preferredHeight: 78
    color: "#f3f4f6"
    radius: 14

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: card.title
                font.pointSize: 11
                font.weight: Font.DemiBold
                color: card.textColor
                Layout.fillWidth: true
            }

            Text {
                text: card.percent + "%"
                font.pointSize: 11
                font.weight: Font.DemiBold
                color: card.textColor
            }
        }

        RoundedProgressBar {
            Layout.fillWidth: true
            barHeight: 8
            value: card.percent / 100
            trackColor: card.trackColor
            fillColor: card.accentColor
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: card.leftText
                font.pointSize: 9
                color: card.secondaryTextColor
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: card.rightText
                font.pointSize: 9
                color: card.secondaryTextColor
            }
        }
    }
}
