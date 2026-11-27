import QtQuick
import org.kde.plasma.configuration
import "../code/i18n.js" as I18n

ConfigModel {
    readonly property string detectedLang: I18n.resolveLanguage("system", Qt.locale().name)

    ConfigCategory {
        name: I18n.tr(detectedLang, "tabClockTime")
        icon: "preferences-system-time"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: I18n.tr(detectedLang, "tabFontsSize")
        icon: "preferences-desktop-font"
        source: "configAppearance.qml"
    }
    ConfigCategory {
        name: I18n.tr(detectedLang, "tabCalendarHolidays")
        icon: "view-calendar"
        source: "configCalendar.qml"
    }
}
