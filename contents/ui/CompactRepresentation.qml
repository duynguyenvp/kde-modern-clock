import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

MouseArea {
    id: compactRoot

    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool isHorizontal: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
    readonly property bool useStackedLayout: isVertical
        || !root.showDateInPanel
        || (root.displayLayout !== "one_line" && height >= Kirigami.Units.gridUnit * 2)

    readonly property int horizontalPadding: Kirigami.Units.smallSpacing
    readonly property int verticalPadding: Math.max(2, Math.floor(Kirigami.Units.smallSpacing / 2))

    readonly property real activeContentWidth: useStackedLayout ? contentColumn.implicitWidth : contentRow.implicitWidth
    readonly property real activeContentHeight: useStackedLayout ? contentColumn.implicitHeight : contentRow.implicitHeight

    readonly property int computedTimePixelSize: {
        if (!root.timeAutoFontSize) {
            return Math.max(8, Math.min(72, root.timeFontSize));
        }
        if (isVertical) {
            return Math.max(10, Math.min(18, Math.floor(width * 0.28)));
        }
        if (useStackedLayout && root.showDateInPanel) {
            return Math.max(11, Math.min(20, Math.floor(height * 0.44)));
        }
        return Math.max(12, Math.min(24, Math.floor(height * 0.60)));
    }

    readonly property int computedDatePixelSize: {
        if (!root.dateAutoFontSize) {
            return Math.max(7, Math.min(48, root.dateFontSize));
        }
        if (isVertical) {
            return Math.max(8, Math.min(12, Math.floor(width * 0.18)));
        }
        if (useStackedLayout) {
            return Math.max(9, Math.min(13, Math.floor(height * 0.28)));
        }
        return Math.max(10, Math.min(15, Math.floor(height * 0.50)));
    }

    readonly property string effectiveTimeFontFamily: root.timeFontFamily.length > 0 ? root.timeFontFamily : Kirigami.Theme.defaultFont.family
    readonly property string effectiveDateFontFamily: root.dateFontFamily.length > 0 ? root.dateFontFamily : Kirigami.Theme.defaultFont.family

    readonly property bool isDarkTheme: {
        var bg = Kirigami.Theme.backgroundColor;
        return (0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b) < 0.5;
    }
    readonly property color dateTextColor: isDarkTheme
        ? Qt.rgba(0.92, 0.94, 0.98, 0.90)
        : Qt.rgba(0.12, 0.15, 0.20, 0.88)

    implicitWidth: Math.ceil(activeContentWidth) + horizontalPadding * 2
    implicitHeight: Math.ceil(activeContentHeight) + verticalPadding * 2

    Layout.minimumWidth: isVertical ? Kirigami.Units.gridUnit * 2 : implicitWidth
    Layout.preferredWidth: isVertical ? -1 : implicitWidth
    Layout.maximumWidth: isVertical ? -1 : implicitWidth

    Layout.minimumHeight: isHorizontal ? Kirigami.Units.gridUnit : implicitHeight
    Layout.preferredHeight: isHorizontal ? -1 : implicitHeight

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    onClicked: {
        root.expanded = !root.expanded;
    }

    // Subtle hover background
    Rectangle {
        anchors.fill: parent
        radius: Kirigami.Units.cornerRadius
        color: compactRoot.containsMouse ? Kirigami.Theme.hoverColor : "transparent"
        opacity: compactRoot.containsMouse ? 0.18 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }

    // Stacked layout (vertical panel, floating/desktop, or standard/tall horizontal panel)
    ColumnLayout {
        id: contentColumn
        anchors.centerIn: parent
        width: compactRoot.isVertical ? Math.max(0, parent.width - compactRoot.horizontalPadding * 2) : implicitWidth
        spacing: 0
        visible: compactRoot.useStackedLayout

        PlasmaComponents.Label {
            id: timeLabelStacked
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: compactRoot.isVertical ? parent.width : -1
            text: root.timeFormatted.full
            font.family: compactRoot.effectiveTimeFontFamily
            font.pixelSize: compactRoot.computedTimePixelSize
            font.bold: root.timeFontBold
            font.italic: root.timeFontItalic
            fontSizeMode: compactRoot.isVertical ? Text.HorizontalFit : Text.FixedSize
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideNone
            color: Kirigami.Theme.textColor
        }

        PlasmaComponents.Label {
            id: dateLabelStacked
            visible: root.showDateInPanel
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: compactRoot.isVertical ? parent.width : -1
            text: root.formattedDate
            font.family: compactRoot.effectiveDateFontFamily
            font.pixelSize: compactRoot.computedDatePixelSize
            font.bold: root.dateFontBold
            font.italic: root.dateFontItalic
            fontSizeMode: compactRoot.isVertical ? Text.HorizontalFit : Text.FixedSize
            horizontalAlignment: Text.AlignHCenter
            elide: compactRoot.isVertical ? Text.ElideRight : Text.ElideNone
            color: compactRoot.dateTextColor
        }
    }

    // Inline layout (thin horizontal panel when date is enabled)
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing
        visible: !compactRoot.useStackedLayout

        PlasmaComponents.Label {
            text: root.timeFormatted.full
            font.family: compactRoot.effectiveTimeFontFamily
            font.pixelSize: compactRoot.computedTimePixelSize
            font.bold: root.timeFontBold
            font.italic: root.timeFontItalic
            color: Kirigami.Theme.textColor
        }

        Rectangle {
            visible: root.showDateInPanel
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 1
            implicitHeight: Math.max(10, Math.round(compactRoot.height * 0.45))
            color: Kirigami.Theme.textColor
            opacity: 0.35
        }

        PlasmaComponents.Label {
            visible: root.showDateInPanel
            text: root.formattedDate
            font.family: compactRoot.effectiveDateFontFamily
            font.pixelSize: compactRoot.computedDatePixelSize
            font.bold: root.dateFontBold
            font.italic: root.dateFontItalic
            color: compactRoot.dateTextColor
        }
    }
}
