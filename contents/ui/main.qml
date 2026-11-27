import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "../code/i18n.js" as I18n
import "../code/timeUtils.js" as TimeUtils
import "../code/vietnamCalendar.js" as VnCal

PlasmoidItem {
    id: root

    property date currentDate: new Date()

    readonly property string configuredLanguage: Plasmoid.configuration.language
    readonly property string effectiveLanguage: I18n.resolveLanguage(configuredLanguage, Qt.locale().name)

    readonly property bool use24HourFormat: Plasmoid.configuration.use24HourFormat
    readonly property bool showSeconds: Plasmoid.configuration.showSeconds
    readonly property bool showDateInPanel: Plasmoid.configuration.showDateInPanel
    readonly property bool useCustomDateFormat: Plasmoid.configuration.useCustomDateFormat
    readonly property string dateFormatPreset: Plasmoid.configuration.dateFormatPreset
    readonly property string customDateFormat: Plasmoid.configuration.customDateFormat
    readonly property bool useSystemTimezone: Plasmoid.configuration.useSystemTimezone
    readonly property string customTimezone: Plasmoid.configuration.customTimezone
    readonly property int firstDayOfWeek: Plasmoid.configuration.firstDayOfWeek
    readonly property bool showVietnamHolidays: Plasmoid.configuration.showVietnamHolidays
    readonly property bool showLunarDate: Plasmoid.configuration.showLunarDate
    readonly property bool showWeekNumbers: Plasmoid.configuration.showWeekNumbers

    readonly property string timeFontFamily: Plasmoid.configuration.timeFontFamily
    readonly property bool timeAutoFontSize: Plasmoid.configuration.timeAutoFontSize
    readonly property int timeFontSize: Plasmoid.configuration.timeFontSize
    readonly property bool timeFontBold: Plasmoid.configuration.timeFontBold
    readonly property bool timeFontItalic: Plasmoid.configuration.timeFontItalic

    readonly property string dateFontFamily: Plasmoid.configuration.dateFontFamily
    readonly property bool dateAutoFontSize: Plasmoid.configuration.dateAutoFontSize
    readonly property int dateFontSize: Plasmoid.configuration.dateFontSize
    readonly property bool dateFontBold: Plasmoid.configuration.dateFontBold
    readonly property bool dateFontItalic: Plasmoid.configuration.dateFontItalic

    readonly property string effectiveTimezone: TimeUtils.getEffectiveTimezone(
        useSystemTimezone,
        customTimezone,
        effectiveLanguage
    )
    readonly property string effectiveDateFormat: TimeUtils.getEffectiveDateFormat(
        useCustomDateFormat,
        dateFormatPreset,
        customDateFormat
    )

    readonly property var timeParts: TimeUtils.getZonedParts(currentDate, effectiveTimezone)
    readonly property var timeFormatted: TimeUtils.formatTime(timeParts, use24HourFormat, showSeconds)
    readonly property string formattedDate: TimeUtils.formatDate(timeParts, effectiveDateFormat, effectiveLanguage)
    readonly property string timezoneOffsetLabel: TimeUtils.getTimezoneOffsetLabel(currentDate, effectiveTimezone)
    readonly property var todayLunar: VnCal.convertSolar2Lunar(timeParts.day, timeParts.month, timeParts.year)
    readonly property string todayLunarText: VnCal.formatLunarFull(todayLunar, effectiveLanguage)

    // Reference to compact item for screen-edge space calculation
    property Item compactAnchorItem: null

    switchWidth: Kirigami.Units.gridUnit * 12
    switchHeight: Kirigami.Units.gridUnit * 12

    toolTipMainText: timeFormatted.full
    toolTipSubText: {
        var lines = [
            formattedDate,
            effectiveTimezone + (timezoneOffsetLabel.length > 0 ? " (" + timezoneOffsetLabel + ")" : "")
        ];
        if (showLunarDate) {
            lines.push(I18n.tr(effectiveLanguage, "lunarPrefix") + ": " + todayLunarText);
        }
        return lines.join("\n");
    }

    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.currentDate = new Date();
        }
    }

    compactRepresentation: CompactRepresentation {
        Component.onCompleted: {
            root.compactAnchorItem = this;
        }
    }

    fullRepresentation: FullRepresentation {}
}
