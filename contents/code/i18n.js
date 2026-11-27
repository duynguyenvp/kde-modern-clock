.pragma library

function resolveLanguage(configuredLang, systemLocaleName) {
    if (configuredLang === "vi" || configuredLang === "en") {
        return configuredLang;
    }
    var loc = systemLocaleName || "";
    if (!loc) {
        try {
            loc = Intl.DateTimeFormat().resolvedOptions().locale || "";
        } catch (e) {
            loc = "";
        }
    }
    if (String(loc).toLowerCase().indexOf("vi") === 0) {
        return "vi";
    }
    return "en";
}

var STRINGS = {
    en: {
        // Tabs
        tabClockTime: "Clock & Time",
        tabFontsSize: "Fonts & Size",
        tabCalendarHolidays: "Calendar & VN Holidays",

        // General / Popup
        systemTime: "System Time",
        systemTag: "System",
        customTag: "Custom",
        lunarPrefix: "Lunar",
        lunarSuffixShort: "Lunar",
        today: "Today",
        prevMonth: "Previous month",
        nextMonth: "Next month",
        monthYearTitle: "{month} {year}",
        weekShort: "Wk",
        publicHolidayBadge: "(Public holiday)",
        vnHolidaysInMonth: "Vietnamese Holidays in {month}",

        // Config General
        sectionPreview: "Preview",
        labelDisplay: "Display:",
        activeTimezone: "Active timezone: {tz}",
        sectionLanguage: "Language",
        labelLanguage: "Interface language:",
        langSystem: "System default ({detected})",
        langEnglish: "English",
        langVietnamese: "Tiếng Việt",
        sectionTimeFormat: "Time Format",
        labelClockSystem: "Clock system:",
        hour24Option: "24-hour (e.g. 18:30)",
        hour12Option: "12-hour AM/PM (e.g. 6:30 PM)",
        showSeconds: "Show seconds",
        sectionDateFormat: "Date Format",
        labelPanel: "Panel:",
        showDateInPanel: "Show date alongside clock",
        labelPreset: "Preset:",
        useCustomDateFormat: "Use custom date format",
        labelCustomFormat: "Custom format:",
        customDatePlaceholder: "e.g. ddd, dd/MM/yyyy",
        dateTokensHelp: "Supported tokens: dd (01-31), d (1-31), MM (01-12), M (1-12), MMM (Nov), MMMM (November), yyyy (2026), yy (26), ddd (Thu), dddd (Thursday).",
        sectionTimezone: "Timezone",
        labelTimezoneSource: "Timezone source:",
        tzSystemDefault: "System default ({tz})",
        tzCustomOption: "Custom timezone",
        labelQuickSelect: "Quick select:",
        labelIanaTz: "IANA Timezone:",
        tzPlaceholder: "e.g. Asia/Ho_Chi_Minh, Asia/Tokyo, America/New_York",
        tzValid: "Valid timezone ({offset})",
        tzInvalid: "Invalid timezone — falling back to system timezone.",

        // Config Appearance
        sectionPanelPreview: "Panel Preview",
        labelSample: "Sample:",
        labelDisplayLayout: "Panel layout:",
        layoutTwoLines: "2 lines (stacked)",
        layoutOneLine: "1 line (inline)",
        systemDefaultFont: "System default ({font})",
        sectionTimeFont: "Time Font",
        sectionDateFont: "Date Font",
        labelFontFamily: "Font family:",
        labelFontSize: "Font size:",
        autoPanelHeight: "Auto-fit to panel height",
        labelManualSize: "Manual size (px):",
        labelFontStyle: "Style:",
        fontBold: "Bold",
        fontItalic: "Italic",

        // Config Calendar
        sectionCalendarDisplay: "Calendar Display",
        labelFirstDayOfWeek: "First day of week:",
        recommendedSuffix: "(Recommended)",
        showWeekNumbers: "Show ISO week numbers",
        sectionVnCalendar: "Vietnamese Calendar & Holidays",
        labelVnHolidays: "Vietnam holidays:",
        showVnHolidays: "Show Vietnamese holidays & Tết on calendar",
        vnHolidaysDesc: "Includes official public holidays (New Year's Day, Lunar New Year's Eve, Tết, Hung Kings' Day, Reunification Day 30/4, Labor Day 1/5, National Day 2/9) and traditional/commemorative days (Lantern Festival, Buddha's Birthday, Vu Lan, Mid-Autumn Festival, Vietnamese Teachers' Day, etc.).",
        showLunarDate: "Show Vietnamese lunar date (UTC+7)"
    },
    vi: {
        // Tabs
        tabClockTime: "Đồng hồ & Thời gian",
        tabFontsSize: "Phông chữ & Kích thước",
        tabCalendarHolidays: "Lịch & Ngày lễ VN",

        // General / Popup
        systemTime: "Giờ hệ thống",
        systemTag: "Hệ thống",
        customTag: "Tuỳ chỉnh",
        lunarPrefix: "Âm lịch",
        lunarSuffixShort: "ÂL",
        today: "Hôm nay",
        prevMonth: "Tháng trước",
        nextMonth: "Tháng sau",
        monthYearTitle: "{month} / {year}",
        weekShort: "Tuần",
        publicHolidayBadge: "(Nghỉ lễ)",
        vnHolidaysInMonth: "Ngày lễ Tết Việt Nam trong {month}",

        // Config General
        sectionPreview: "Xem trước",
        labelDisplay: "Hiển thị:",
        activeTimezone: "Múi giờ đang dùng: {tz}",
        sectionLanguage: "Ngôn ngữ",
        labelLanguage: "Ngôn ngữ giao diện:",
        langSystem: "Theo hệ điều hành ({detected})",
        langEnglish: "English",
        langVietnamese: "Tiếng Việt",
        sectionTimeFormat: "Định dạng giờ",
        labelClockSystem: "Hệ giờ:",
        hour24Option: "24 giờ (VD: 18:30)",
        hour12Option: "12 giờ AM/PM (VD: 6:30 PM)",
        showSeconds: "Hiển thị giây",
        sectionDateFormat: "Định dạng ngày tháng",
        labelPanel: "Thanh panel:",
        showDateInPanel: "Hiển thị ngày tháng cùng đồng hồ",
        labelPreset: "Mẫu có sẵn:",
        useCustomDateFormat: "Sử dụng định dạng ngày tùy chỉnh",
        labelCustomFormat: "Định dạng tùy chỉnh:",
        customDatePlaceholder: "VD: ddd, dd/MM/yyyy",
        dateTokensHelp: "Ký hiệu hỗ trợ: dd (ngày 01-31), d (1-31), MM (tháng 01-12), M (1-12), MMM (Thg 11), MMMM (Tháng 11), yyyy (2026), yy (26), ddd (T5), dddd (Thứ Năm).",
        sectionTimezone: "Múi giờ (Timezone)",
        labelTimezoneSource: "Nguồn múi giờ:",
        tzSystemDefault: "Mặc định theo hệ thống ({tz})",
        tzCustomOption: "Tuỳ chỉnh múi giờ",
        labelQuickSelect: "Chọn nhanh:",
        labelIanaTz: "IANA Timezone:",
        tzPlaceholder: "VD: Asia/Ho_Chi_Minh, Asia/Tokyo, America/New_York",
        tzValid: "Múi giờ hợp lệ ({offset})",
        tzInvalid: "Múi giờ không hợp lệ — widget sẽ tạm dùng múi giờ hệ thống.",

        // Config Appearance
        sectionPanelPreview: "Xem trước trên Panel",
        labelSample: "Mẫu:",
        labelDisplayLayout: "Kiểu hiển thị:",
        layoutTwoLines: "2 dòng (trên dưới)",
        layoutOneLine: "1 dòng (ngang)",
        systemDefaultFont: "Mặc định hệ thống ({font})",
        sectionTimeFont: "Phông chữ Thời gian",
        sectionDateFont: "Phông chữ Ngày tháng",
        labelFontFamily: "Kiểu chữ:",
        labelFontSize: "Cỡ chữ:",
        autoPanelHeight: "Tự động theo chiều cao panel",
        labelManualSize: "Cỡ chữ thủ công (px):",
        labelFontStyle: "Định dạng:",
        fontBold: "In đậm",
        fontItalic: "In nghiêng",

        // Config Calendar
        sectionCalendarDisplay: "Hiển thị lịch",
        labelFirstDayOfWeek: "Ngày bắt đầu của tuần:",
        recommendedSuffix: "(Khuyên dùng)",
        showWeekNumbers: "Hiển thị cột số tuần (ISO)",
        sectionVnCalendar: "Lịch Việt Nam & Ngày lễ Tết",
        labelVnHolidays: "Ngày lễ Việt Nam:",
        showVnHolidays: "Hiển thị các ngày lễ Tết của Việt Nam trên lịch",
        vnHolidaysDesc: "Bao gồm ngày lễ nghỉ chính thức (Tết Dương lịch, Đêm Giao thừa, Tết Nguyên Đán, Giỗ Tổ Hùng Vương 10/3 ÂL, 30/4, 1/5, Quốc khánh 2/9) và các ngày lễ truyền thống/kỷ niệm (Rằm tháng Giêng, 8/3, Phật Đản, Đoan Ngọ, Vu Lan, Trung Thu, 20/10, 20/11, Ông Công Ông Táo...).",
        showLunarDate: "Hiển thị ngày Âm lịch (theo múi giờ Việt Nam UTC+7)"
    }
};

function tr(lang, key, params) {
    var dict = STRINGS[lang === "vi" ? "vi" : "en"] || STRINGS.en;
    var text = (dict && dict[key] !== undefined) ? dict[key] : (STRINGS.en[key] || key);
    if (params) {
        for (var k in params) {
            if (Object.prototype.hasOwnProperty.call(params, k)) {
                text = text.replace(new RegExp("\\{" + k + "\\}", "g"), String(params[k]));
            }
        }
    }
    return text;
}
