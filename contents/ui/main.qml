import QtQuick
import QtQuick.Layouts
import QtCore
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

import "Providers.js" as Providers

PlasmoidItem {
    id: root

    // Desliga o "fundo" padrão que o Plasma desenha atrás de toda applet
    // (a chapa/borda escura) — nosso próprio card branco já é o fundo.
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // No desktop (Planar) mostra o card cheio direto, como no Android.
    // Em painel/system tray mostra só o ícone e abre o card num popup ao clicar
    // — sem isso, o card de 340x260 seria embutido inteiro num painel fino.
    preferredRepresentation: Plasmoid.formFactor === PlasmaCore.Types.Planar ? fullRepresentation : null

    // Valores de fallback, usados até a primeira busca real completar
    // (ou permanentemente para provedores sem integração ainda, como Codex/Gemini).
    property int sessionUsagePct: 57
    property int weeklyUsagePct: 56
    property string sessionResetText: "Reinicia em 2 h 40 min"
    property string weeklyResetText: "Reinicia 29/07, 23:59"
    property string sessionRightText: "46% usado"
    property string weeklyRightText: "56% usado"
    property bool isFetching: false

    readonly property var currentProvider: Providers.byId(Plasmoid.configuration.provider)
    readonly property bool isDark: Plasmoid.configuration.theme === "dark"
    readonly property color cardBgColor: isDark ? Plasmoid.configuration.bgColorDark : Plasmoid.configuration.bgColorLight
    readonly property color innerCardColor: isDark ? "#111827" : "#f3f4f6"
    readonly property color textColor: isDark ? "#f9fafb" : "#1f2937"
    readonly property color secondaryTextColor: isDark ? "#9ca3af" : "#6b7280"
    readonly property color trackColor: isDark ? "#374151" : "#e2e5ea"

    // "Reinicia em Xh Ymin" — usado pro reset da sessão (janela de 5h).
    function formatRelativeReset(isoString) {
        var diffMs = new Date(isoString).getTime() - Date.now();
        if (diffMs <= 0) return "Reinicia em instantes";
        var totalMin = Math.round(diffMs / 60000);
        var h = Math.floor(totalMin / 60);
        var m = totalMin % 60;
        return h > 0 ? "Reinicia em " + h + " h " + m + " min" : "Reinicia em " + m + " min";
    }

    // "Reinicia dom., 04:59" — usado pro reset semanal. Nomes fixos em vez de
    // depender do locale do sistema (que pode estar em inglês mesmo com o
    // resto da interface em português).
    readonly property var weekdayAbbrevs: ["dom.", "seg.", "ter.", "qua.", "qui.", "sex.", "sáb."]

    function formatWeekdayReset(isoString) {
        var d = new Date(isoString);
        var hh = String(d.getHours()).padStart(2, "0");
        var mm = String(d.getMinutes()).padStart(2, "0");
        return "Reinicia " + root.weekdayAbbrevs[d.getDay()] + ", " + hh + ":" + mm;
    }

    function applyClaudeUsage(data) {
        root.sessionUsagePct = Math.round(data.five_hour.utilization);
        root.weeklyUsagePct = Math.round(data.seven_day.utilization);
        root.sessionResetText = formatRelativeReset(data.five_hour.resets_at);
        root.weeklyResetText = formatWeekdayReset(data.seven_day.resets_at);
        root.sessionRightText = root.sessionUsagePct + "% usado";
        root.weeklyRightText = root.weeklyUsagePct + "% usado";
    }

    // Lê os dados de uso de um arquivo local (~/.local/share/llm-quota-widget/
    // claude-usage.json), mantido atualizado sozinho por um serviço systemd
    // em segundo plano (veja tools/claude-usage-service). Esse serviço guarda
    // sua sessão logada num Chromium headless próprio, então o widget nunca
    // precisa lidar com cookies nem pedir nada manual no dia a dia.
    readonly property string usageFilePath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/share/llm-quota-widget/claude-usage.json"

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);
            try {
                root.applyClaudeUsage(JSON.parse(data["stdout"]));
            } catch (e) {
                console.warn("llm-quota-widget: sem dados de uso do Claude ainda em " + root.usageFilePath + ". Veja tools/claude-usage-service para configurar o serviço em segundo plano.");
            }
            root.isFetching = false;
        }
    }

    function fetchApiUsage() {
        if (root.isFetching) return;
        root.isFetching = true;
        if (root.currentProvider.id === "claude") {
            executable.connectSource("cat \"" + root.usageFilePath + "\"");
        } else {
            fetchDelay.start(); // sem dados reais ainda: só dá tempo do spin ser visível
        }
    }

    Component.onCompleted: fetchApiUsage()

    // Além do refresh manual, busca de novo periodicamente — o serviço em
    // segundo plano já atualiza o arquivo sozinho a cada ~10 min.
    Timer {
        interval: 5 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.fetchApiUsage()
    }

    Timer {
        id: fetchDelay
        interval: 350
        onTriggered: root.isFetching = false
    }

    compactRepresentation: MouseArea {
        id: compactRoot
        Layout.minimumWidth: Kirigami.Units.iconSizes.small
        Layout.minimumHeight: Kirigami.Units.iconSizes.small

        onClicked: root.expanded = !root.expanded

        ProviderIcon {
            anchors.fill: parent
            anchors.margins: 2
            provider: root.currentProvider
        }
    }

    fullRepresentation: Item {
        id: rootItem
        // A mágica para o plasmoidviewer não esmagar o widget:
        Layout.minimumWidth: 340
        Layout.minimumHeight: 260
        Layout.preferredWidth: 340
        Layout.preferredHeight: 260

        // Card Principal
        Rectangle {
            id: mainCard
            anchors.fill: parent
            anchors.margins: 12
            color: root.cardBgColor
            radius: 22

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 6
                radius: 18
                samples: 37
                color: "#33000000"
                transparentBorder: true
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                // Cabeçalho
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ProviderIcon {
                        provider: root.currentProvider
                        size: 20
                    }

                    ProviderWordmark {
                        provider: root.currentProvider
                        size: 18
                        color: root.textColor
                        Layout.fillWidth: true
                    }

                    // Botão de refresh "flat": sem moldura de botão, apenas o
                    // ícone com feedback sutil de hover/clique e spin durante o fetch.
                    Item {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26

                        Kirigami.Icon {
                            id: refreshIcon
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            source: "view-refresh"
                            isMask: true
                            color: root.secondaryTextColor
                            opacity: refreshArea.containsMouse || root.isFetching ? 1.0 : 0.65

                            Behavior on opacity {
                                NumberAnimation { duration: 120 }
                            }

                            Behavior on scale {
                                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                            }

                            RotationAnimation {
                                target: refreshIcon
                                running: root.isFetching
                                loops: Animation.Infinite
                                from: 0
                                to: 360
                                duration: 800
                            }
                        }

                        MouseArea {
                            id: refreshArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: !root.isFetching
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.fetchApiUsage()
                            onPressed: refreshIcon.scale = 0.85
                            onReleased: refreshIcon.scale = 1.0
                            onCanceled: refreshIcon.scale = 1.0
                        }
                    }
                }

                UsageCard {
                    title: "Limites semanais"
                    percent: root.weeklyUsagePct
                    leftText: root.weeklyResetText
                    rightText: root.weeklyRightText
                    accentColor: root.currentProvider.color
                    color: root.innerCardColor
                    textColor: root.textColor
                    secondaryTextColor: root.secondaryTextColor
                    trackColor: root.trackColor
                }

                UsageCard {
                    title: "Sessão atual"
                    percent: root.sessionUsagePct
                    leftText: root.sessionResetText
                    rightText: root.sessionRightText
                    accentColor: root.currentProvider.color
                    color: root.innerCardColor
                    textColor: root.textColor
                    secondaryTextColor: root.secondaryTextColor
                    trackColor: root.trackColor
                }

                Item { Layout.fillHeight: true } // Espaçador no final para empurrar tudo pra cima
            }
        }
    }
}
