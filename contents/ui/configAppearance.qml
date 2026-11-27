import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "../code/i18n.js" as I18n

KCM.SimpleKCM {
    id: appearancePage

    property string cfg_displayLayout: "two_lines"
    property string cfg_timeFontFamily
    property alias cfg_timeAutoFontSize: timeAutoSizeCheck.checked
    property alias cfg_timeFontSize: timeFontSizeSpin.value
    property alias cfg_timeFontBold: timeBoldCheck.checked
    property alias cfg_timeFontItalic: timeItalicCheck.checked

    property string cfg_dateFontFamily
    property alias cfg_dateAutoFontSize: dateAutoSizeCheck.checked
    property alias cfg_dateFontSize: dateFontSizeSpin.value
    property alias cfg_dateFontBold: dateBoldCheck.checked
    property alias cfg_dateFontItalic: dateItalicCheck.checked

    readonly property string lang: I18n.resolveLanguage(Plasmoid.configuration.language, Qt.locale().name)
    property var fontList: []

    function buildFontList() {
        var families = Qt.fontFamilies();
        var list = [{
            id: "",
            label: I18n.tr(lang, "systemDefaultFont", { font: Kirigami.Theme.defaultFont.family })
        }];
        for (var i = 0; i < families.length; i++) {
            list.push({ id: families[i], label: families[i] });
        }
        fontList = list;
        syncCombo(timeFontCombo, cfg_timeFontFamily);
        syncCombo(dateFontCombo, cfg_dateFontFamily);
    }

    Component.onCompleted: buildFontList()
    onLangChanged: buildFontList()

    function syncCombo(combo, familyId) {
        for (var i = 0; i < fontList.length; i++) {
            if (fontList[i].id === familyId) {
                combo.currentIndex = i;
                return;
            }
        }
        combo.currentIndex = 0;
    }

    Kirigami.FormLayout {
        // ===== LIVE PREVIEW =====
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "sectionPanelPreview")
        }

        Rectangle {
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "labelSample")
            readonly property bool previewOneLine: cfg_displayLayout === "one_line"
            readonly property real activePreviewWidth: previewOneLine ? previewRow.implicitWidth : previewCol.implicitWidth
            readonly property real activePreviewHeight: previewOneLine ? previewRow.implicitHeight : previewCol.implicitHeight
            implicitWidth: Math.max(120, activePreviewWidth + 24)
            implicitHeight: activePreviewHeight + 16
            radius: Kirigami.Units.cornerRadius
            color: Qt.rgba(
                Kirigami.Theme.textColor.r,
                Kirigami.Theme.textColor.g,
                Kirigami.Theme.textColor.b,
                0.08
            )
            border.width: 1
            border.color: Qt.rgba(
                Kirigami.Theme.textColor.r,
                Kirigami.Theme.textColor.g,
                Kirigami.Theme.textColor.b,
                0.15
            )

            ColumnLayout {
                id: previewCol
                anchors.centerIn: parent
                spacing: 0
                visible: !parent.previewOneLine

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: "18:30"
                    font.family: cfg_timeFontFamily.length > 0 ? cfg_timeFontFamily : Kirigami.Theme.defaultFont.family
                    font.pixelSize: cfg_timeAutoFontSize ? 16 : cfg_timeFontSize
                    font.bold: cfg_timeFontBold
                    font.italic: cfg_timeFontItalic
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: "26/11/2026"
                    font.family: cfg_dateFontFamily.length > 0 ? cfg_dateFontFamily : Kirigami.Theme.defaultFont.family
                    font.pixelSize: cfg_dateAutoFontSize ? 11 : cfg_dateFontSize
                    font.bold: cfg_dateFontBold
                    font.italic: cfg_dateFontItalic
                    opacity: 0.85
                }
            }

            RowLayout {
                id: previewRow
                anchors.centerIn: parent
                spacing: Kirigami.Units.smallSpacing
                visible: parent.previewOneLine

                QQC2.Label {
                    Layout.alignment: Qt.AlignVCenter
                    text: "18:30"
                    font.family: cfg_timeFontFamily.length > 0 ? cfg_timeFontFamily : Kirigami.Theme.defaultFont.family
                    font.pixelSize: cfg_timeAutoFontSize ? 16 : cfg_timeFontSize
                    font.bold: cfg_timeFontBold
                    font.italic: cfg_timeFontItalic
                }

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 1
                    implicitHeight: Math.max(12, Math.round((cfg_timeAutoFontSize ? 16 : cfg_timeFontSize) * 0.85))
                    color: Kirigami.Theme.textColor
                    opacity: 0.35
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignVCenter
                    text: "26/11/2026"
                    font.family: cfg_dateFontFamily.length > 0 ? cfg_dateFontFamily : Kirigami.Theme.defaultFont.family
                    font.pixelSize: cfg_dateAutoFontSize ? 12 : cfg_dateFontSize
                    font.bold: cfg_dateFontBold
                    font.italic: cfg_dateFontItalic
                    opacity: 0.85
                }
            }
        }

        QQC2.ComboBox {
            id: displayLayoutCombo
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "labelDisplayLayout")
            Layout.fillWidth: true
            model: [
                { id: "two_lines", label: I18n.tr(appearancePage.lang, "layoutTwoLines") },
                { id: "one_line", label: I18n.tr(appearancePage.lang, "layoutOneLine") }
            ]
            textRole: "label"
            currentIndex: cfg_displayLayout === "one_line" ? 1 : 0
            onActivated: function(index) {
                appearancePage.cfg_displayLayout = model[index].id;
            }
        }

        // ===== TIME FONT SETTINGS =====
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "sectionTimeFont")
        }

        QQC2.ComboBox {
            id: timeFontCombo
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "labelFontFamily")
            Layout.fillWidth: true
            model: appearancePage.fontList
            textRole: "label"
            onActivated: function(index) {
                appearancePage.cfg_timeFontFamily = appearancePage.fontList[index].id;
            }
        }

        QQC2.CheckBox {
            id: timeAutoSizeCheck
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "labelFontSize")
            text: I18n.tr(appearancePage.lang, "autoPanelHeight")
        }

        QQC2.SpinBox {
            id: timeFontSizeSpin
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "labelManualSize")
            enabled: !timeAutoSizeCheck.checked
            from: 8
            to: 72
            editable: true
        }

        RowLayout {
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "labelFontStyle")
            spacing: Kirigami.Units.largeSpacing

            QQC2.CheckBox {
                id: timeBoldCheck
                text: I18n.tr(appearancePage.lang, "fontBold")
            }

            QQC2.CheckBox {
                id: timeItalicCheck
                text: I18n.tr(appearancePage.lang, "fontItalic")
            }
        }

        // ===== DATE FONT SETTINGS =====
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "sectionDateFont")
        }

        QQC2.ComboBox {
            id: dateFontCombo
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "labelFontFamily")
            Layout.fillWidth: true
            model: appearancePage.fontList
            textRole: "label"
            onActivated: function(index) {
                appearancePage.cfg_dateFontFamily = appearancePage.fontList[index].id;
            }
        }

        QQC2.CheckBox {
            id: dateAutoSizeCheck
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "labelFontSize")
            text: I18n.tr(appearancePage.lang, "autoPanelHeight")
        }

        QQC2.SpinBox {
            id: dateFontSizeSpin
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "labelManualSize")
            enabled: !dateAutoSizeCheck.checked
            from: 7
            to: 48
            editable: true
        }

        RowLayout {
            Kirigami.FormData.label: I18n.tr(appearancePage.lang, "labelFontStyle")
            spacing: Kirigami.Units.largeSpacing

            QQC2.CheckBox {
                id: dateBoldCheck
                text: I18n.tr(appearancePage.lang, "fontBold")
            }

            QQC2.CheckBox {
                id: dateItalicCheck
                text: I18n.tr(appearancePage.lang, "fontItalic")
            }
        }
    }
}
