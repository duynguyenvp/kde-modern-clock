import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Window
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "../code/i18n.js" as I18n
import "../code/timeUtils.js" as TimeUtils
import "../code/vietnamCalendar.js" as VnCal

Item {
    id: fullRoot

    // Adaptive high-contrast palette for both Dark and Light Plasma themes
    readonly property bool isDarkTheme: {
        var bg = Kirigami.Theme.backgroundColor;
        return (0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b) < 0.5;
    }

    readonly property color primaryTextColor: Kirigami.Theme.textColor
    readonly property color secondaryTextColor: isDarkTheme
        ? Qt.rgba(0.90, 0.93, 0.97, 0.88)
        : Qt.rgba(0.14, 0.17, 0.22, 0.85)
    readonly property color mutedTextColor: isDarkTheme
        ? Qt.rgba(0.84, 0.88, 0.93, 0.78)
        : Qt.rgba(0.22, 0.26, 0.32, 0.74)
    readonly property color accentTextColor: isDarkTheme
        ? Qt.lighter(Kirigami.Theme.highlightColor, 1.65)
        : Qt.darker(Kirigami.Theme.highlightColor, 1.35)
    readonly property color publicHolidayColor: isDarkTheme ? "#ff6b72" : "#c62828"
    readonly property color traditionalHolidayColor: isDarkTheme ? "#fbbf24" : "#b45309"
    readonly property color todayTextColor: {
        var c = Kirigami.Theme.highlightColor;
        var lum = 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
        return lum > 0.62 ? "#111827" : "#ffffff";
    }
    readonly property color cardBgColor: isDarkTheme
        ? Qt.rgba(1, 1, 1, 0.07)
        : Qt.rgba(0, 0, 0, 0.05)
    readonly property color cardBorderColor: isDarkTheme
        ? Qt.rgba(1, 1, 1, 0.14)
        : Qt.rgba(0, 0, 0, 0.12)
    readonly property color headerBgColor: isDarkTheme
        ? Qt.rgba(1, 1, 1, 0.08)
        : Qt.rgba(
            Kirigami.Theme.highlightColor.r,
            Kirigami.Theme.highlightColor.g,
            Kirigami.Theme.highlightColor.b,
            0.10
        )
    readonly property color headerBorderColor: isDarkTheme
        ? Qt.rgba(1, 1, 1, 0.16)
        : Qt.rgba(
            Kirigami.Theme.highlightColor.r,
            Kirigami.Theme.highlightColor.g,
            Kirigami.Theme.highlightColor.b,
            0.28
        )

    // Screen-edge margin so popup never gets clipped or obscured by screen edges
    readonly property int edgeMargin: 24
    readonly property int panelSafetyAllowance: 48

    // Ideal comfortable dimensions for the clock + calendar popup
    readonly property int idealWidth: root.showWeekNumbers ? 430 : 396
    readonly property int idealHeight: {
        var h = 500;
        if (root.showLunarDate) h += 24;
        if (root.showVietnamHolidays && monthHolidays.length > 0) {
            h += Math.min(130, 38 + monthHolidays.length * 24);
        }
        return h;
    }

    // Dynamically computed safe maximum space relative to screen edges
    property int safeMaxWidth: idealWidth
    property int safeMaxHeight: idealHeight
    property bool adjustingWindowGeometry: false

    Layout.minimumWidth: Math.min(300, safeMaxWidth)
    Layout.minimumHeight: Math.min(340, safeMaxHeight)
    Layout.preferredWidth: Math.min(idealWidth, safeMaxWidth)
    Layout.preferredHeight: Math.min(idealHeight, safeMaxHeight)
    Layout.maximumWidth: safeMaxWidth
    Layout.maximumHeight: safeMaxHeight

    // Calendar navigation state
    property int displayYear: root.timeParts.year
    property int displayMonth: root.timeParts.month
    property int selectedYear: root.timeParts.year
    property int selectedMonth: root.timeParts.month
    property int selectedDay: root.timeParts.day

    readonly property var weekdayHeaders: TimeUtils.getOrderedWeekdayHeaders(root.firstDayOfWeek, root.effectiveLanguage)
    readonly property var calendarData: VnCal.buildMonthGrid(
        displayYear,
        displayMonth,
        root.firstDayOfWeek,
        root.timeParts,
        root.showVietnamHolidays,
        root.effectiveLanguage
    )
    readonly property var calendarCells: calendarData.cells
    readonly property var monthHolidays: calendarData.monthHolidays
    readonly property var weekNumbers: calendarData.weekNumbers

    readonly property var selectedCellInfo: {
        var lunar = VnCal.convertSolar2Lunar(selectedDay, selectedMonth, selectedYear);
        var holidays = root.showVietnamHolidays
            ? VnCal.getVietnamHolidays(selectedDay, selectedMonth, selectedYear, lunar, root.effectiveLanguage)
            : [];
        var d = new Date(selectedYear, selectedMonth - 1, selectedDay);
        var parts = {
            year: selectedYear,
            month: selectedMonth,
            day: selectedDay,
            weekday: d.getDay()
        };
        return {
            solarFull: TimeUtils.formatDate(parts, "dddd, dd/MM/yyyy", root.effectiveLanguage),
            lunarFull: VnCal.formatLunarFull(lunar, root.effectiveLanguage),
            holidays: holidays
        };
    }

    // Calculate available screen space from the widget's position to screen edges
    function recalculateAvailableSpace() {
        var screenAvailW = (Screen.desktopAvailableWidth > 0) ? Screen.desktopAvailableWidth : Screen.width;
        var screenAvailH = (Screen.desktopAvailableHeight > 0) ? Screen.desktopAvailableHeight : Screen.height;

        if (screenAvailW <= 0) screenAvailW = 1280;
        if (screenAvailH <= 0) screenAvailH = 720;

        var availW = screenAvailW - edgeMargin * 2;
        var availH = screenAvailH - edgeMargin * 2;

        // Account for panel location and distance from screen edges
        var loc = Plasmoid.location;
        if (loc === PlasmaCore.Types.TopEdge || loc === PlasmaCore.Types.BottomEdge) {
            availH = Math.max(280, screenAvailH - edgeMargin * 2 - panelSafetyAllowance);
        } else if (loc === PlasmaCore.Types.LeftEdge || loc === PlasmaCore.Types.RightEdge) {
            availW = Math.max(280, screenAvailW - edgeMargin * 2 - panelSafetyAllowance);
        }

        // If we can inspect the compact representation's global coordinates, refine edge clearance
        if (root.compactAnchorItem && root.compactAnchorItem.visible) {
            try {
                var globalPos = root.compactAnchorItem.mapToGlobal(0, 0);
                var screenLeft = Screen.virtualX;
                var screenTop = Screen.virtualY;
                var screenRight = screenLeft + screenAvailW;
                var screenBottom = screenTop + screenAvailH;

                if (loc === PlasmaCore.Types.TopEdge) {
                    var spaceBelow = screenBottom - (globalPos.y + root.compactAnchorItem.height) - edgeMargin;
                    if (spaceBelow > 240) {
                        availH = Math.min(availH, spaceBelow);
                    }
                } else if (loc === PlasmaCore.Types.BottomEdge) {
                    var spaceAbove = globalPos.y - screenTop - edgeMargin;
                    if (spaceAbove > 240) {
                        availH = Math.min(availH, spaceAbove);
                    }
                } else if (loc === PlasmaCore.Types.LeftEdge) {
                    var spaceRight = screenRight - (globalPos.x + root.compactAnchorItem.width) - edgeMargin;
                    if (spaceRight > 260) {
                        availW = Math.min(availW, spaceRight);
                    }
                } else if (loc === PlasmaCore.Types.RightEdge) {
                    var spaceLeft = globalPos.x - screenLeft - edgeMargin;
                    if (spaceLeft > 260) {
                        availW = Math.min(availW, spaceLeft);
                    }
                }
            } catch (e) {
                // Ignore if item is not yet attached to a window
            }
        }

        safeMaxWidth = Math.max(280, Math.floor(availW));
        safeMaxHeight = Math.max(300, Math.floor(availH));
    }

    // Clamp popup window position & dimensions inside the available screen bounds
    function clampPopupWindowToScreen() {
        var win = fullRoot.Window.window;
        if (!win || !win.visible || adjustingWindowGeometry) {
            return;
        }
        // Only adjust if this is a popup dialog (not embedded directly on desktop)
        if (Plasmoid.location === PlasmaCore.Types.Floating) {
            return;
        }

        adjustingWindowGeometry = true;
        try {
            var screenLeft = Screen.virtualX;
            var screenTop = Screen.virtualY;
            var screenAvailW = (Screen.desktopAvailableWidth > 0) ? Screen.desktopAvailableWidth : Screen.width;
            var screenAvailH = (Screen.desktopAvailableHeight > 0) ? Screen.desktopAvailableHeight : Screen.height;
            var maxRight = screenLeft + screenAvailW - edgeMargin;
            var maxBottom = screenTop + screenAvailH - edgeMargin;
            var minLeft = screenLeft + edgeMargin;
            var minTop = screenTop + edgeMargin;

            // Clamp dimensions first if window exceeds available screen space
            var maxWinW = Math.max(280, screenAvailW - edgeMargin * 2);
            var maxWinH = Math.max(300, screenAvailH - edgeMargin * 2);
            if (win.width > maxWinW) {
                win.width = maxWinW;
            }
            if (win.height > maxWinH) {
                win.height = maxWinH;
            }

            // Clamp X position so popup is not clipped on left or right screen edges
            if (win.x + win.width > maxRight) {
                win.x = Math.max(minLeft, maxRight - win.width);
            }
            if (win.x < minLeft) {
                win.x = minLeft;
            }

            // Clamp Y position so popup is not clipped on top or bottom screen edges
            if (win.y + win.height > maxBottom) {
                win.y = Math.max(minTop, maxBottom - win.height);
            }
            if (win.y < minTop) {
                win.y = minTop;
            }
        } catch (e) {
            // Wayland compositors manage popup positioning via xdg-positioner; width/height limits still apply
        }
        adjustingWindowGeometry = false;
    }

    function goToToday() {
        displayYear = root.timeParts.year;
        displayMonth = root.timeParts.month;
        selectedYear = root.timeParts.year;
        selectedMonth = root.timeParts.month;
        selectedDay = root.timeParts.day;
    }

    function previousMonth() {
        if (displayMonth === 1) {
            displayMonth = 12;
            displayYear -= 1;
        } else {
            displayMonth -= 1;
        }
    }

    function nextMonth() {
        if (displayMonth === 12) {
            displayMonth = 1;
            displayYear += 1;
        } else {
            displayMonth += 1;
        }
    }

    Component.onCompleted: {
        recalculateAvailableSpace();
    }

    Connections {
        target: root
        function onExpandedChanged() {
            if (root.expanded) {
                fullRoot.goToToday();
                fullRoot.recalculateAvailableSpace();
                clampTimer.restart();
            }
        }
    }

    Connections {
        target: fullRoot.Window.window
        ignoreUnknownSignals: true
        function onVisibleChanged() {
            if (fullRoot.Window.window && fullRoot.Window.window.visible) {
                fullRoot.recalculateAvailableSpace();
                clampTimer.restart();
            }
        }
        function onWidthChanged() {
            clampTimer.restart();
        }
        function onHeightChanged() {
            clampTimer.restart();
        }
    }

    Timer {
        id: clampTimer
        interval: 30
        repeat: false
        onTriggered: {
            fullRoot.recalculateAvailableSpace();
            fullRoot.clampPopupWindowToScreen();
        }
    }

    QQC2.ScrollView {
        id: mainScrollView
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

        ColumnLayout {
            id: popupContent
            width: mainScrollView.availableWidth
            spacing: Kirigami.Units.smallSpacing * 1.5

            // ===== HEADER: DIGITAL CLOCK & TIMEZONE =====
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.smallSpacing
                Layout.bottomMargin: 0
                implicitHeight: headerColumn.implicitHeight + Kirigami.Units.largeSpacing * 1.5
                radius: Kirigami.Units.cornerRadius * 1.5
                color: fullRoot.headerBgColor
                border.width: 1
                border.color: fullRoot.headerBorderColor

                ColumnLayout {
                    id: headerColumn
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.largeSpacing * 0.75
                    spacing: Kirigami.Units.smallSpacing * 0.75

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        // Big Time Display
                        Row {
                            spacing: 4
                            PlasmaComponents.Label {
                                text: root.timeFormatted.main
                                font.family: root.timeFontFamily.length > 0 ? root.timeFontFamily : Kirigami.Theme.defaultFont.family
                                font.pixelSize: 34
                                font.bold: root.timeFontBold
                                font.italic: root.timeFontItalic
                                color: Kirigami.Theme.textColor
                            }
                            PlasmaComponents.Label {
                                visible: root.showSeconds
                                text: ":" + root.timeFormatted.seconds
                                font.family: root.timeFontFamily.length > 0 ? root.timeFontFamily : Kirigami.Theme.defaultFont.family
                                font.pixelSize: 20
                                font.weight: Font.Medium
                                font.italic: root.timeFontItalic
                                anchors.baseline: parent.children[0].baseline
                                color: fullRoot.secondaryTextColor
                            }
                            PlasmaComponents.Label {
                                visible: !root.use24HourFormat
                                text: root.timeFormatted.period
                                font.family: root.timeFontFamily.length > 0 ? root.timeFontFamily : Kirigami.Theme.defaultFont.family
                                font.pixelSize: 14
                                font.bold: true
                                font.italic: root.timeFontItalic
                                anchors.baseline: parent.children[0].baseline
                                color: fullRoot.accentTextColor
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Timezone Pill
                        Rectangle {
                            implicitWidth: tzLabel.implicitWidth + 14
                            implicitHeight: tzLabel.implicitHeight + 8
                            radius: height / 2
                            color: fullRoot.cardBgColor
                            border.width: 1
                            border.color: fullRoot.cardBorderColor
                            Layout.alignment: Qt.AlignTop

                            PlasmaComponents.Label {
                                id: tzLabel
                                anchors.centerIn: parent
                                text: root.timezoneOffsetLabel
                                font.pixelSize: 11
                                font.bold: true
                                color: fullRoot.primaryTextColor
                            }
                        }
                    }

                    // Formatted Solar Date
                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        text: root.formattedDate
                        font.family: root.dateFontFamily.length > 0 ? root.dateFontFamily : Kirigami.Theme.defaultFont.family
                        font.pixelSize: 14
                        font.italic: root.dateFontItalic
                        font.weight: root.dateFontBold ? Font.Bold : Font.Medium
                        color: fullRoot.primaryTextColor
                        elide: Text.ElideRight
                    }

                    // Timezone Name + Today's Lunar Date
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        PlasmaComponents.Label {
                            text: root.effectiveTimezone + " (" + I18n.tr(root.effectiveLanguage, root.useSystemTimezone ? "systemTag" : "customTag") + ")"
                            font.pixelSize: 11
                            color: fullRoot.secondaryTextColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    PlasmaComponents.Label {
                        visible: root.showLunarDate
                        Layout.fillWidth: true
                        text: I18n.tr(root.effectiveLanguage, "lunarPrefix") + ": " + root.todayLunarText
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: fullRoot.accentTextColor
                        elide: Text.ElideRight
                    }
                }
            }

            // ===== MONTH NAVIGATION BAR =====
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.ToolButton {
                    icon.name: "go-previous"
                    PlasmaComponents.ToolTip.text: I18n.tr(root.effectiveLanguage, "prevMonth")
                    PlasmaComponents.ToolTip.visible: hovered
                    onClicked: fullRoot.previousMonth()
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: I18n.tr(root.effectiveLanguage, "monthYearTitle", {
                        month: TimeUtils.getMonthFullName(fullRoot.displayMonth, root.effectiveLanguage),
                        year: fullRoot.displayYear
                    })
                    font.pixelSize: 15
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    color: Kirigami.Theme.textColor
                }

                PlasmaComponents.Button {
                    text: I18n.tr(root.effectiveLanguage, "today")
                    flat: true
                    font.pixelSize: 12
                    onClicked: fullRoot.goToToday()
                }

                PlasmaComponents.ToolButton {
                    icon.name: "go-next"
                    PlasmaComponents.ToolTip.text: I18n.tr(root.effectiveLanguage, "nextMonth")
                    PlasmaComponents.ToolTip.visible: hovered
                    onClicked: fullRoot.nextMonth()
                }
            }

            // ===== CALENDAR GRID =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
                spacing: 4

                // Weekday Header Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    PlasmaComponents.Label {
                        visible: root.showWeekNumbers
                        Layout.preferredWidth: 26
                        text: I18n.tr(root.effectiveLanguage, "weekShort")
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        color: fullRoot.mutedTextColor
                    }

                    Repeater {
                        model: fullRoot.weekdayHeaders
                        delegate: PlasmaComponents.Label {
                            required property var modelData
                            Layout.fillWidth: true
                            text: modelData.shortName
                            font.pixelSize: 12
                            font.weight: modelData.isWeekend ? Font.Bold : Font.Medium
                            horizontalAlignment: Text.AlignHCenter
                            color: modelData.isWeekend
                                ? fullRoot.primaryTextColor
                                : fullRoot.secondaryTextColor
                        }
                    }
                }

                // 6 Week Rows
                Repeater {
                    model: 6
                    delegate: RowLayout {
                        id: weekRow
                        required property int index
                        Layout.fillWidth: true
                        spacing: 2

                        // Optional ISO week number column
                        PlasmaComponents.Label {
                            visible: root.showWeekNumbers
                            Layout.preferredWidth: 26
                            text: fullRoot.weekNumbers[weekRow.index]
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: fullRoot.mutedTextColor
                        }

                        Repeater {
                            model: 7
                            delegate: Rectangle {
                                id: dayCell
                                required property int index
                                readonly property var cell: fullRoot.calendarCells[weekRow.index * 7 + index]
                                readonly property bool isSelected: (
                                    cell.year === fullRoot.selectedYear &&
                                    cell.month === fullRoot.selectedMonth &&
                                    cell.day === fullRoot.selectedDay
                                )

                                Layout.fillWidth: true
                                Layout.preferredHeight: root.showLunarDate ? 42 : 34
                                radius: Kirigami.Units.cornerRadius

                                color: {
                                    if (cell.isToday) {
                                        return Kirigami.Theme.highlightColor;
                                    }
                                    if (isSelected) {
                                        return Qt.rgba(
                                            Kirigami.Theme.highlightColor.r,
                                            Kirigami.Theme.highlightColor.g,
                                            Kirigami.Theme.highlightColor.b,
                                            0.22
                                        );
                                    }
                                    if (cellMouse.containsMouse) {
                                        return Qt.rgba(
                                            Kirigami.Theme.textColor.r,
                                            Kirigami.Theme.textColor.g,
                                            Kirigami.Theme.textColor.b,
                                            0.09
                                        );
                                    }
                                    return "transparent";
                                }

                                border.width: isSelected && !cell.isToday ? 1.5 : 0
                                border.color: Kirigami.Theme.highlightColor

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 1

                                    PlasmaComponents.Label {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: cell.day
                                        font.pixelSize: 13
                                        font.bold: cell.isToday || cell.hasPublicHoliday || cell.isWeekend
                                        color: {
                                            if (cell.isToday) {
                                                return fullRoot.todayTextColor;
                                            }
                                            if (cell.hasPublicHoliday) {
                                                return fullRoot.publicHolidayColor;
                                            }
                                            return fullRoot.primaryTextColor;
                                        }
                                        opacity: cell.isCurrentMonth ? 1.0 : 0.45
                                    }

                                    PlasmaComponents.Label {
                                        visible: root.showLunarDate
                                        Layout.alignment: Qt.AlignHCenter
                                        text: cell.lunarShort
                                        font.pixelSize: 10
                                        font.bold: cell.lunarDay === 1
                                        color: {
                                            if (cell.isToday) {
                                                return fullRoot.todayTextColor;
                                            }
                                            if (cell.lunarDay === 1) {
                                                return fullRoot.accentTextColor;
                                            }
                                            return fullRoot.mutedTextColor;
                                        }
                                        opacity: cell.isCurrentMonth ? (cell.isToday ? 0.92 : 1.0) : 0.42
                                    }
                                }

                                // Holiday Indicator Dot
                                Rectangle {
                                    visible: root.showVietnamHolidays && cell.hasHoliday
                                    width: 5
                                    height: 5
                                    radius: 2.5
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 3
                                    color: {
                                        if (cell.isToday) {
                                            return fullRoot.todayTextColor;
                                        }
                                        return cell.hasPublicHoliday
                                            ? fullRoot.publicHolidayColor
                                            : fullRoot.traditionalHolidayColor;
                                    }
                                    opacity: cell.isCurrentMonth ? 1.0 : 0.5
                                }

                                MouseArea {
                                    id: cellMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        fullRoot.selectedYear = cell.year;
                                        fullRoot.selectedMonth = cell.month;
                                        fullRoot.selectedDay = cell.day;
                                        if (!cell.isCurrentMonth) {
                                            fullRoot.displayYear = cell.year;
                                            fullRoot.displayMonth = cell.month;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ===== SELECTED DAY DETAILS =====
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
                implicitHeight: detailColumn.implicitHeight + Kirigami.Units.largeSpacing
                radius: Kirigami.Units.cornerRadius
                color: fullRoot.cardBgColor
                border.width: 1
                border.color: fullRoot.cardBorderColor

                ColumnLayout {
                    id: detailColumn
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing * 1.5
                    spacing: 3

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        text: fullRoot.selectedCellInfo.solarFull
                        font.pixelSize: 12
                        font.bold: true
                        color: fullRoot.primaryTextColor
                        elide: Text.ElideRight
                    }

                    PlasmaComponents.Label {
                        visible: root.showLunarDate
                        Layout.fillWidth: true
                        text: I18n.tr(root.effectiveLanguage, "lunarPrefix") + ": " + fullRoot.selectedCellInfo.lunarFull
                        font.pixelSize: 11
                        color: fullRoot.secondaryTextColor
                        elide: Text.ElideRight
                    }

                    Repeater {
                        model: root.showVietnamHolidays ? fullRoot.selectedCellInfo.holidays : []
                        delegate: RowLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle {
                                width: 7
                                height: 7
                                radius: 3.5
                                color: modelData.isPublicHoliday
                                    ? fullRoot.publicHolidayColor
                                    : fullRoot.traditionalHolidayColor
                            }

                            PlasmaComponents.Label {
                                Layout.fillWidth: true
                                text: modelData.name + (modelData.isPublicHoliday ? (" " + I18n.tr(root.effectiveLanguage, "publicHolidayBadge")) : "")
                                font.pixelSize: 11
                                font.bold: modelData.isPublicHoliday
                                color: modelData.isPublicHoliday
                                    ? fullRoot.publicHolidayColor
                                    : fullRoot.primaryTextColor
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }

            // ===== VIETNAM HOLIDAYS IN CURRENT MONTH =====
            ColumnLayout {
                visible: root.showVietnamHolidays && fullRoot.monthHolidays.length > 0
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                spacing: 4

                PlasmaComponents.Label {
                    text: I18n.tr(root.effectiveLanguage, "vnHolidaysInMonth", {
                        month: TimeUtils.getMonthFullName(fullRoot.displayMonth, root.effectiveLanguage)
                    })
                    font.pixelSize: 11
                    font.bold: true
                    color: fullRoot.secondaryTextColor
                }

                Repeater {
                    model: fullRoot.monthHolidays
                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: holidayRow.implicitHeight + 8
                        radius: Kirigami.Units.cornerRadius
                        color: holidayMouse.containsMouse
                            ? fullRoot.cardBgColor
                            : "transparent"

                        RowLayout {
                            id: holidayRow
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 8

                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                color: modelData.isPublicHoliday
                                    ? fullRoot.publicHolidayColor
                                    : fullRoot.traditionalHolidayColor
                            }

                            PlasmaComponents.Label {
                                text: TimeUtils.pad2(modelData.day) + "/" + TimeUtils.pad2(modelData.month)
                                font.pixelSize: 11
                                font.bold: true
                                Layout.preferredWidth: 38
                                color: modelData.isPublicHoliday
                                    ? fullRoot.publicHolidayColor
                                    : fullRoot.primaryTextColor
                            }

                            PlasmaComponents.Label {
                                Layout.fillWidth: true
                                text: modelData.name
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                color: fullRoot.primaryTextColor
                            }

                            PlasmaComponents.Label {
                                visible: modelData.calendar === "lunar"
                                text: modelData.lunarText
                                font.pixelSize: 10
                                color: fullRoot.mutedTextColor
                            }
                        }

                        MouseArea {
                            id: holidayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                fullRoot.selectedYear = modelData.year;
                                fullRoot.selectedMonth = modelData.month;
                                fullRoot.selectedDay = modelData.day;
                            }
                        }
                    }
                }
            }
        }
    }
}
