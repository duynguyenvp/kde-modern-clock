import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "../code/i18n.js" as I18n
import "../code/timeUtils.js" as TimeUtils

KCM.SimpleKCM {
    id: generalPage

    property string cfg_language
    property bool cfg_use24HourFormat
    property alias cfg_showSeconds: showSecondsCheck.checked
    property alias cfg_showDateInPanel: showDateCheck.checked
    property string cfg_dateFormatPreset
    property alias cfg_customDateFormat: customDateField.text
    property alias cfg_useCustomDateFormat: useCustomDateCheck.checked
    property bool cfg_useSystemTimezone
    property alias cfg_customTimezone: customTimezoneField.text

    readonly property string detectedSystemLang: I18n.resolveLanguage("system", Qt.locale().name)
    readonly property string lang: I18n.resolveLanguage(cfg_language, Qt.locale().name)
    readonly property string systemTz: TimeUtils.getSystemTimezone(lang)
    readonly property bool customTzValid: TimeUtils.isValidTimezone(cfg_customTimezone)
    readonly property string previewTz: TimeUtils.getEffectiveTimezone(cfg_useSystemTimezone, cfg_customTimezone, lang)
    readonly property var previewParts: TimeUtils.getZonedParts(new Date(), previewTz)
    readonly property string previewTime: TimeUtils.formatTime(previewParts, cfg_use24HourFormat, cfg_showSeconds).full
    readonly property string previewDate: TimeUtils.formatDate(
        previewParts,
        TimeUtils.getEffectiveDateFormat(cfg_useCustomDateFormat, cfg_dateFormatPreset, cfg_customDateFormat),
        lang
    )

    readonly property var languageOptions: [
        {
            id: "system",
            label: I18n.tr(lang, "langSystem", {
                detected: detectedSystemLang === "vi" ? "Tiếng Việt" : "English"
            })
        },
        { id: "en", label: I18n.tr(lang, "langEnglish") },
        { id: "vi", label: I18n.tr(lang, "langVietnamese") }
    ]

    readonly property var datePresets: TimeUtils.getDateFormatPresets(lang)
    readonly property var commonTimezones: TimeUtils.getCommonTimezones(lang)

    function syncCombos() {
        for (var l = 0; l < languageOptions.length; l++) {
            if (languageOptions[l].id === cfg_language) {
                languageCombo.currentIndex = l;
                break;
            }
        }
        for (var i = 0; i < datePresets.length; i++) {
            if (datePresets[i].pattern === cfg_dateFormatPreset) {
                datePresetCombo.currentIndex = i;
                break;
            }
        }
        for (var j = 0; j < commonTimezones.length; j++) {
            if (commonTimezones[j].id === cfg_customTimezone) {
                timezonePresetCombo.currentIndex = j;
                break;
            }
        }
    }

    Component.onCompleted: syncCombos()
    onLangChanged: syncCombos()

    Kirigami.FormLayout {
        // ===== PREVIEW =====
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "sectionPreview")
        }

        ColumnLayout {
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "labelDisplay")
            spacing: 2

            QQC2.Label {
                text: generalPage.previewTime + (cfg_showDateInPanel ? ("   •   " + generalPage.previewDate) : "")
                font.bold: true
                font.pixelSize: 15
            }
            QQC2.Label {
                text: I18n.tr(generalPage.lang, "activeTimezone", {
                    tz: generalPage.previewTz + " (" + TimeUtils.getTimezoneOffsetLabel(new Date(), generalPage.previewTz) + ")"
                })
                font.pixelSize: 11
                opacity: 0.72
            }
        }

        // ===== LANGUAGE =====
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "sectionLanguage")
        }

        QQC2.ComboBox {
            id: languageCombo
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "labelLanguage")
            Layout.fillWidth: true
            model: generalPage.languageOptions
            textRole: "label"
            onActivated: function(index) {
                generalPage.cfg_language = generalPage.languageOptions[index].id;
            }
        }

        // ===== TIME FORMAT =====
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "sectionTimeFormat")
        }

        QQC2.ButtonGroup {
            id: hourFormatGroup
        }

        QQC2.RadioButton {
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "labelClockSystem")
            text: I18n.tr(generalPage.lang, "hour24Option")
            checked: generalPage.cfg_use24HourFormat
            QQC2.ButtonGroup.group: hourFormatGroup
            onToggled: if (checked) generalPage.cfg_use24HourFormat = true
        }

        QQC2.RadioButton {
            text: I18n.tr(generalPage.lang, "hour12Option")
            checked: !generalPage.cfg_use24HourFormat
            QQC2.ButtonGroup.group: hourFormatGroup
            onToggled: if (checked) generalPage.cfg_use24HourFormat = false
        }

        QQC2.CheckBox {
            id: showSecondsCheck
            text: I18n.tr(generalPage.lang, "showSeconds")
        }

        // ===== DATE FORMAT =====
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "sectionDateFormat")
        }

        QQC2.CheckBox {
            id: showDateCheck
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "labelPanel")
            text: I18n.tr(generalPage.lang, "showDateInPanel")
        }

        QQC2.ComboBox {
            id: datePresetCombo
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "labelPreset")
            Layout.fillWidth: true
            enabled: !useCustomDateCheck.checked
            model: generalPage.datePresets
            textRole: "label"
            onActivated: function(index) {
                generalPage.cfg_dateFormatPreset = generalPage.datePresets[index].pattern;
            }
        }

        QQC2.CheckBox {
            id: useCustomDateCheck
            text: I18n.tr(generalPage.lang, "useCustomDateFormat")
        }

        QQC2.TextField {
            id: customDateField
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "labelCustomFormat")
            Layout.fillWidth: true
            enabled: useCustomDateCheck.checked
            placeholderText: I18n.tr(generalPage.lang, "customDatePlaceholder")
        }

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            font.pixelSize: 11
            opacity: 0.72
            text: I18n.tr(generalPage.lang, "dateTokensHelp")
        }

        // ===== TIMEZONE =====
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "sectionTimezone")
        }

        QQC2.ButtonGroup {
            id: tzModeGroup
        }

        QQC2.RadioButton {
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "labelTimezoneSource")
            text: I18n.tr(generalPage.lang, "tzSystemDefault", { tz: generalPage.systemTz })
            checked: generalPage.cfg_useSystemTimezone
            QQC2.ButtonGroup.group: tzModeGroup
            onToggled: if (checked) generalPage.cfg_useSystemTimezone = true
        }

        QQC2.RadioButton {
            text: I18n.tr(generalPage.lang, "tzCustomOption")
            checked: !generalPage.cfg_useSystemTimezone
            QQC2.ButtonGroup.group: tzModeGroup
            onToggled: if (checked) generalPage.cfg_useSystemTimezone = false
        }

        QQC2.ComboBox {
            id: timezonePresetCombo
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "labelQuickSelect")
            Layout.fillWidth: true
            enabled: !generalPage.cfg_useSystemTimezone
            model: generalPage.commonTimezones
            textRole: "label"
            onActivated: function(index) {
                customTimezoneField.text = generalPage.commonTimezones[index].id;
            }
        }

        QQC2.TextField {
            id: customTimezoneField
            Kirigami.FormData.label: I18n.tr(generalPage.lang, "labelIanaTz")
            Layout.fillWidth: true
            enabled: !generalPage.cfg_useSystemTimezone
            placeholderText: I18n.tr(generalPage.lang, "tzPlaceholder")
        }

        QQC2.Label {
            visible: !generalPage.cfg_useSystemTimezone
            Layout.fillWidth: true
            font.pixelSize: 11
            color: generalPage.customTzValid ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
            text: generalPage.customTzValid
                ? I18n.tr(generalPage.lang, "tzValid", { offset: TimeUtils.getTimezoneOffsetLabel(new Date(), generalPage.cfg_customTimezone) })
                : I18n.tr(generalPage.lang, "tzInvalid")
        }
    }
}
