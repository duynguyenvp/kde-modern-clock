import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "../code/i18n.js" as I18n
import "../code/timeUtils.js" as TimeUtils

KCM.SimpleKCM {
    id: calendarPage

    property int cfg_firstDayOfWeek
    property alias cfg_showVietnamHolidays: showVnHolidaysCheck.checked
    property alias cfg_showLunarDate: showLunarCheck.checked
    property alias cfg_showWeekNumbers: showWeekNumbersCheck.checked

    readonly property string lang: I18n.resolveLanguage(Plasmoid.configuration.language, Qt.locale().name)
    readonly property var weekdayOptions: TimeUtils.getWeekdayOptions(
        lang,
        I18n.tr(lang, "recommendedSuffix")
    )

    function syncFirstDayCombo() {
        for (var i = 0; i < weekdayOptions.length; i++) {
            if (weekdayOptions[i].value === cfg_firstDayOfWeek) {
                firstDayCombo.currentIndex = i;
                return;
            }
        }
    }

    Component.onCompleted: syncFirstDayCombo()
    onLangChanged: syncFirstDayCombo()

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: I18n.tr(calendarPage.lang, "sectionCalendarDisplay")
        }

        QQC2.ComboBox {
            id: firstDayCombo
            Kirigami.FormData.label: I18n.tr(calendarPage.lang, "labelFirstDayOfWeek")
            Layout.fillWidth: true
            model: calendarPage.weekdayOptions
            textRole: "label"
            onActivated: function(index) {
                calendarPage.cfg_firstDayOfWeek = calendarPage.weekdayOptions[index].value;
            }
        }

        QQC2.CheckBox {
            id: showWeekNumbersCheck
            text: I18n.tr(calendarPage.lang, "showWeekNumbers")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: I18n.tr(calendarPage.lang, "sectionVnCalendar")
        }

        QQC2.CheckBox {
            id: showVnHolidaysCheck
            Kirigami.FormData.label: I18n.tr(calendarPage.lang, "labelVnHolidays")
            text: I18n.tr(calendarPage.lang, "showVnHolidays")
        }

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            font.pixelSize: 11
            opacity: 0.72
            text: I18n.tr(calendarPage.lang, "vnHolidaysDesc")
        }

        QQC2.CheckBox {
            id: showLunarCheck
            text: I18n.tr(calendarPage.lang, "showLunarDate")
        }
    }
}
