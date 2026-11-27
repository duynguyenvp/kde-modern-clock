.pragma library

var WEEKDAY_FULL = {
    en: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
    vi: ["Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"]
};

var WEEKDAY_SHORT = {
    en: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
    vi: ["CN", "T2", "T3", "T4", "T5", "T6", "T7"]
};

var MONTH_FULL = {
    en: [
        "", "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ],
    vi: [
        "", "Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6",
        "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"
    ]
};

var MONTH_SHORT = {
    en: [
        "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ],
    vi: [
        "", "Thg 1", "Thg 2", "Thg 3", "Thg 4", "Thg 5", "Thg 6",
        "Thg 7", "Thg 8", "Thg 9", "Thg 10", "Thg 11", "Thg 12"
    ]
};

function normLang(lang) {
    return lang === "vi" ? "vi" : "en";
}

function getMonthFullName(month, lang) {
    var l = normLang(lang);
    return MONTH_FULL[l][month] || String(month);
}

function getCommonTimezones(lang) {
    var vi = (normLang(lang) === "vi");
    return [
        { id: "Asia/Ho_Chi_Minh", label: vi ? "Asia/Ho_Chi_Minh (Việt Nam, UTC+7)" : "Asia/Ho_Chi_Minh (Vietnam, UTC+7)" },
        { id: "Asia/Bangkok", label: vi ? "Asia/Bangkok (Thái Lan, UTC+7)" : "Asia/Bangkok (Thailand, UTC+7)" },
        { id: "Asia/Singapore", label: "Asia/Singapore (Singapore, UTC+8)" },
        { id: "Asia/Shanghai", label: vi ? "Asia/Shanghai (Trung Quốc, UTC+8)" : "Asia/Shanghai (China, UTC+8)" },
        { id: "Asia/Tokyo", label: vi ? "Asia/Tokyo (Nhật Bản, UTC+9)" : "Asia/Tokyo (Japan, UTC+9)" },
        { id: "Asia/Seoul", label: vi ? "Asia/Seoul (Hàn Quốc, UTC+9)" : "Asia/Seoul (South Korea, UTC+9)" },
        { id: "Asia/Kolkata", label: vi ? "Asia/Kolkata (Ấn Độ, UTC+5:30)" : "Asia/Kolkata (India, UTC+5:30)" },
        { id: "Asia/Dubai", label: "Asia/Dubai (UAE, UTC+4)" },
        { id: "Australia/Sydney", label: vi ? "Australia/Sydney (Úc)" : "Australia/Sydney (Australia)" },
        { id: "UTC", label: vi ? "UTC (Giờ phối hợp quốc tế)" : "UTC (Coordinated Universal Time)" },
        { id: "Europe/London", label: vi ? "Europe/London (Anh)" : "Europe/London (UK)" },
        { id: "Europe/Paris", label: vi ? "Europe/Paris (Pháp)" : "Europe/Paris (France)" },
        { id: "Europe/Berlin", label: vi ? "Europe/Berlin (Đức)" : "Europe/Berlin (Germany)" },
        { id: "Europe/Moscow", label: vi ? "Europe/Moscow (Nga, UTC+3)" : "Europe/Moscow (Russia, UTC+3)" },
        { id: "America/New_York", label: vi ? "America/New_York (Mỹ - Đông)" : "America/New_York (US Eastern)" },
        { id: "America/Chicago", label: vi ? "America/Chicago (Mỹ - Trung)" : "America/Chicago (US Central)" },
        { id: "America/Denver", label: vi ? "America/Denver (Mỹ - Núi)" : "America/Denver (US Mountain)" },
        { id: "America/Los_Angeles", label: vi ? "America/Los_Angeles (Mỹ - Tây)" : "America/Los_Angeles (US Pacific)" },
        { id: "Pacific/Auckland", label: "Pacific/Auckland (New Zealand)" }
    ];
}

function getDateFormatPresets(lang) {
    var vi = (normLang(lang) === "vi");
    return [
        { pattern: "dd/MM/yyyy", label: "dd/MM/yyyy (26/11/2026)" },
        { pattern: "dd-MM-yyyy", label: "dd-MM-yyyy (26-11-2026)" },
        { pattern: "yyyy-MM-dd", label: "yyyy-MM-dd (2026-11-26)" },
        { pattern: "MM/dd/yyyy", label: "MM/dd/yyyy (11/26/2026)" },
        { pattern: "ddd, dd/MM/yyyy", label: vi ? "ddd, dd/MM/yyyy (T5, 26/11/2026)" : "ddd, dd/MM/yyyy (Thu, 26/11/2026)" },
        { pattern: "ddd, dd/MM", label: vi ? "ddd, dd/MM (T5, 26/11)" : "ddd, dd/MM (Thu, 26/11)" },
        { pattern: "dddd, dd MMMM yyyy", label: vi ? "dddd, dd MMMM yyyy (Thứ Năm, 26 Tháng 11 2026)" : "dddd, dd MMMM yyyy (Thursday, 26 November 2026)" },
        { pattern: "dd MMM yyyy", label: vi ? "dd MMM yyyy (26 Thg 11 2026)" : "dd MMM yyyy (26 Nov 2026)" }
    ];
}

function pad2(num) {
    return (num < 10 ? "0" : "") + num;
}

function getSystemTimezone(lang) {
    var fallback = (normLang(lang) === "vi") ? "Giờ hệ thống" : "System Time";
    try {
        var tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
        if (tz && tz.length > 0) {
            if ((tz === "UTC" || tz === "Etc/UTC") && new Date().getTimezoneOffset() !== 0) {
                return fallback;
            }
            return tz;
        }
    } catch (e) {
        // Fallback below
    }
    return fallback;
}

function isValidTimezone(tz) {
    if (!tz || typeof tz !== "string" || tz.trim().length === 0) {
        return false;
    }
    try {
        new Intl.DateTimeFormat("en-US", { timeZone: tz.trim() });
        return true;
    } catch (e) {
        return false;
    }
}

function getEffectiveTimezone(useSystemTimezone, customTimezone, lang) {
    if (!useSystemTimezone && isValidTimezone(customTimezone)) {
        return customTimezone.trim();
    }
    return getSystemTimezone(lang);
}

function weekdayShortToIndex(wd) {
    switch (wd) {
    case "Sun": return 0;
    case "Mon": return 1;
    case "Tue": return 2;
    case "Wed": return 3;
    case "Thu": return 4;
    case "Fri": return 5;
    case "Sat": return 6;
    default: return 0;
    }
}

function getZonedParts(date, timeZone) {
    var d = date || new Date();
    var valid = isValidTimezone(timeZone);

    if (valid) {
        try {
            var fmt = new Intl.DateTimeFormat("en-US", {
                timeZone: timeZone,
                year: "numeric",
                month: "numeric",
                day: "numeric",
                hour: "numeric",
                minute: "numeric",
                second: "numeric",
                weekday: "short",
                hour12: false
            });
            var parts = fmt.formatToParts(d);
            var map = {};
            for (var i = 0; i < parts.length; i++) {
                map[parts[i].type] = parts[i].value;
            }
            var hour = parseInt(map.hour, 10);
            if (hour === 24) {
                hour = 0;
            }
            return {
                year: parseInt(map.year, 10),
                month: parseInt(map.month, 10),
                day: parseInt(map.day, 10),
                hour: isNaN(hour) ? d.getHours() : hour,
                minute: parseInt(map.minute, 10),
                second: parseInt(map.second, 10),
                weekday: weekdayShortToIndex(map.weekday),
                timeZone: timeZone
            };
        } catch (e) {
            // Fall through to local time
        }
    }

    return {
        year: d.getFullYear(),
        month: d.getMonth() + 1,
        day: d.getDate(),
        hour: d.getHours(),
        minute: d.getMinutes(),
        second: d.getSeconds(),
        weekday: d.getDay(),
        timeZone: timeZone || ""
    };
}

function getTimezoneOffsetLabel(date, timeZone) {
    var d = date || new Date();
    try {
        var zoned = getZonedParts(d, timeZone);
        var asUtcMs = Date.UTC(
            zoned.year,
            zoned.month - 1,
            zoned.day,
            zoned.hour,
            zoned.minute,
            zoned.second
        );
        var actualUtcMs = Date.UTC(
            d.getUTCFullYear(),
            d.getUTCMonth(),
            d.getUTCDate(),
            d.getUTCHours(),
            d.getUTCMinutes(),
            d.getUTCSeconds()
        );
        var diffMinutes = Math.round((asUtcMs - actualUtcMs) / 60000);
        if (diffMinutes === 0) {
            return "UTC+0";
        }
        var sign = diffMinutes > 0 ? "+" : "-";
        var absMin = Math.abs(diffMinutes);
        var hours = Math.floor(absMin / 60);
        var mins = absMin % 60;
        if (mins === 0) {
            return "UTC" + sign + hours;
        }
        return "UTC" + sign + hours + ":" + pad2(mins);
    } catch (e) {
        return "";
    }
}

function formatTime(parts, use24Hour, showSeconds) {
    var h = parts.hour;
    var period = "";
    if (!use24Hour) {
        period = h >= 12 ? "PM" : "AM";
        h = h % 12;
        if (h === 0) {
            h = 12;
        }
    }
    var hh = use24Hour ? pad2(h) : String(h);
    var mm = pad2(parts.minute);
    var ss = pad2(parts.second);
    var main = hh + ":" + mm;
    var full = showSeconds ? (main + ":" + ss) : main;
    if (!use24Hour) {
        full += " " + period;
    }
    return {
        main: main,
        seconds: ss,
        period: period,
        full: full
    };
}

function formatDate(parts, pattern, lang) {
    var l = normLang(lang);
    var fmt = (pattern && pattern.trim().length > 0) ? pattern : "dd/MM/yyyy";
    var wd = (parts.weekday >= 0 && parts.weekday <= 6) ? parts.weekday : 0;
    var m = (parts.month >= 1 && parts.month <= 12) ? parts.month : 1;

    return fmt.replace(/dddd|ddd|MMMM|MMM|MM|M|dd|d|yyyy|yy/g, function(token) {
        switch (token) {
        case "dddd": return WEEKDAY_FULL[l][wd];
        case "ddd": return WEEKDAY_SHORT[l][wd];
        case "MMMM": return MONTH_FULL[l][m];
        case "MMM": return MONTH_SHORT[l][m];
        case "MM": return pad2(m);
        case "M": return String(m);
        case "dd": return pad2(parts.day);
        case "d": return String(parts.day);
        case "yyyy": return String(parts.year);
        case "yy": return String(parts.year).slice(-2);
        default: return token;
        }
    });
}

function getEffectiveDateFormat(useCustomDateFormat, dateFormatPreset, customDateFormat) {
    if (useCustomDateFormat && customDateFormat && customDateFormat.trim().length > 0) {
        return customDateFormat.trim();
    }
    if (dateFormatPreset && dateFormatPreset.trim().length > 0) {
        return dateFormatPreset.trim();
    }
    return "dd/MM/yyyy";
}

function getOrderedWeekdayHeaders(firstDayOfWeek, lang) {
    var l = normLang(lang);
    var start = (firstDayOfWeek >= 0 && firstDayOfWeek <= 6) ? firstDayOfWeek : 1;
    var headers = [];
    for (var i = 0; i < 7; i++) {
        var idx = (start + i) % 7;
        headers.push({
            index: idx,
            shortName: WEEKDAY_SHORT[l][idx],
            fullName: WEEKDAY_FULL[l][idx],
            isWeekend: (idx === 0 || idx === 6)
        });
    }
    return headers;
}

function getWeekdayOptions(lang, recommendedSuffix) {
    var l = normLang(lang);
    var order = [1, 0, 2, 3, 4, 5, 6];
    var list = [];
    for (var i = 0; i < order.length; i++) {
        var val = order[i];
        var label = WEEKDAY_FULL[l][val];
        if (val === 1 && recommendedSuffix) {
            label += " " + recommendedSuffix;
        }
        list.push({ value: val, label: label });
    }
    return list;
}
