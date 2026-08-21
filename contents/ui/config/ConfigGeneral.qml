import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

import ".."
import "../Providers.js" as Providers

KCM.SimpleKCM {
    id: root

    property string cfg_provider: "claude"
    property string cfg_theme: "light"
    property string cfg_bgColorLight: "#ffffff"
    property string cfg_bgColorDark: "#1f2937"

    readonly property bool isDark: cfg_theme === "dark"
    readonly property var currentProvider: Providers.byId(cfg_provider)
    // Cor efetivamente exibida: cada tema guarda (e edita) sua própria cor de fundo,
    // então trocar Claro/Escuro nunca deixa texto claro sobre fundo claro (ou vice-versa).
    readonly property string effectiveBgColor: isDark ? cfg_bgColorDark : cfg_bgColorLight

    function setEffectiveBgColor(value) {
        if (isDark) {
            cfg_bgColorDark = value;
        } else {
            cfg_bgColorLight = value;
        }
    }

    ColumnLayout {
        width: root.width
        spacing: 22

        // ---- Provedor ----
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Kirigami.Heading {
                text: i18n("Provedor")
                level: 5
                color: Kirigami.Theme.disabledTextColor
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: Providers.list

                    delegate: Rectangle {
                        id: pill
                        required property var modelData

                        readonly property bool selected: root.cfg_provider === modelData.id

                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        radius: 12
                        color: selected ? "#ffffff" : "#e9ebef"
                        border.color: selected ? modelData.color : "transparent"
                        border.width: selected ? 2 : 0

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            ProviderIcon {
                                provider: pill.modelData
                                size: 16
                            }
                            ProviderWordmark {
                                provider: pill.modelData
                                size: 14
                                color: "#1f2937"
                            }
                            Kirigami.Icon {
                                source: "checkmark"
                                visible: pill.selected
                                color: pill.modelData.color
                                Layout.preferredWidth: 14
                                Layout.preferredHeight: 14
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.cfg_provider = pill.modelData.id
                        }
                    }
                }
            }
        }

        // ---- Preview ----
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Kirigami.Heading {
                text: i18n("Preview")
                level: 5
                color: Kirigami.Theme.disabledTextColor
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: previewColumn.implicitHeight + 36
                radius: 20
                color: root.effectiveBgColor

                ColumnLayout {
                    id: previewColumn
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        ProviderIcon {
                            provider: root.currentProvider
                            size: 18
                        }
                        ProviderWordmark {
                            provider: root.currentProvider
                            size: 16
                            color: root.isDark ? "#f9fafb" : "#1f2937"
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "Atualizado · 10:34"
                            font.pointSize: 8
                            color: root.isDark ? "#9ca3af" : "#6b7280"
                        }
                    }

                    UsageCard {
                        title: i18n("Limites semanais")
                        percent: 81
                        leftText: "Reinicia qua., 23:59"
                        rightText: "78% da semana"
                        accentColor: root.currentProvider.color
                        color: root.isDark ? "#111827" : "#f3f4f6"
                        textColor: root.isDark ? "#f9fafb" : "#1f2937"
                        secondaryTextColor: root.isDark ? "#9ca3af" : "#6b7280"
                        trackColor: root.isDark ? "#374151" : "#e2e5ea"
                    }

                    UsageCard {
                        title: i18n("Sessão atual")
                        percent: 2
                        leftText: "Reinicia em 4 h 55 min"
                        rightText: "1% das 5 h"
                        accentColor: root.currentProvider.color
                        color: root.isDark ? "#111827" : "#f3f4f6"
                        textColor: root.isDark ? "#f9fafb" : "#1f2937"
                        secondaryTextColor: root.isDark ? "#9ca3af" : "#6b7280"
                        trackColor: root.isDark ? "#374151" : "#e2e5ea"
                    }
                }
            }
        }

        // ---- Tema ----
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Kirigami.Heading {
                text: i18n("Tema")
                level: 5
                color: Kirigami.Theme.disabledTextColor
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 10
                    color: !root.isDark ? "#ffffff" : "#e9ebef"
                    border.width: !root.isDark ? 1 : 0
                    border.color: "#d1d5db"

                    Text {
                        anchors.centerIn: parent
                        text: i18n("Claro")
                        font.weight: Font.DemiBold
                        color: "#1f2937"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.cfg_theme = "light"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 10
                    color: root.isDark ? "#1f2937" : "#e9ebef"
                    border.width: root.isDark ? 1 : 0
                    border.color: "#4b5563"

                    Text {
                        anchors.centerIn: parent
                        text: i18n("Escuro")
                        font.weight: Font.DemiBold
                        color: root.isDark ? "#f9fafb" : "#1f2937"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.cfg_theme = "dark"
                    }
                }
            }
        }

        // ---- Cor de fundo ----
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Kirigami.Heading {
                    text: i18n("Cor de fundo")
                    level: 5
                    color: Kirigami.Theme.disabledTextColor
                    Layout.fillWidth: true
                }
                Label {
                    text: root.effectiveBgColor + (root.isDark ? " · " + i18n("tema escuro") : " · " + i18n("tema claro"))
                    color: Kirigami.Theme.disabledTextColor
                }
            }

            ColorWheel {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
                color: root.effectiveBgColor
                onColorPicked: (newColor) => root.setEffectiveBgColor(newColor.toString())
            }
        }
    }
}
