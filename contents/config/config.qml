import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Geral")
        icon: "preferences-desktop-color"
        source: "config/ConfigGeneral.qml"
    }
}
