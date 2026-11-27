.pragma library

/*
 * Vietnamese Lunar Calendar & Holidays calculation
 * Astronomical algorithm adapted from Ho Ngoc Duc (UTC+7 Vietnam standard time).
 */

var PI = Math.PI;
var VIETNAM_TZ = 7.0;

var CAN = ["Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ", "Canh", "Tân", "Nhâm", "Quý"];
var CHI = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"];

var LUNAR_MONTH_NAMES_VI = [
    "",
    "Tháng Giêng",
    "Tháng Hai",
    "Tháng Ba",
    "Tháng Tư",
    "Tháng Năm",
    "Tháng Sáu",
    "Tháng Bảy",
    "Tháng Tám",
    "Tháng Chín",
    "Tháng Mười",
    "Tháng Mười Một",
    "Tháng Chạp"
];

function INT(d) {
    return Math.floor(d);
}

function jdFromDate(dd, mm, yy) {
    var a = INT((14 - mm) / 12);
    var y = yy + 4800 - a;
    var m = mm + 12 * a - 3;
    var jd = dd + INT((153 * m + 2) / 5) + 365 * y + INT(y / 4) - INT(y / 100) + INT(y / 400) - 32045;
    if (jd < 2299161) {
        jd = dd + INT((153 * m + 2) / 5) + 365 * y + INT(y / 4) - 32083;
    }
    return jd;
}

function newMoon(k) {
    var T = k / 1236.85;
    var T2 = T * T;
    var T3 = T2 * T;
    var dr = PI / 180;
    var Jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * T2 - 0.000000155 * T3;
    Jd1 = Jd1 + 0.00033 * Math.sin((166.56 + 132.87 * T - 0.009173 * T2) * dr);
    var M = 359.2242 + 29.10535608 * k - 0.0000333 * T2 - 0.00000347 * T3;
    var Mpr = 306.0253 + 385.81691806 * k + 0.0107306 * T2 + 0.00001236 * T3;
    var F = 21.2964 + 390.67050646 * k - 0.0016528 * T2 - 0.00000239 * T3;
    var C1 = (0.1734 - 0.000393 * T) * Math.sin(M * dr) + 0.0021 * Math.sin(2 * dr * M);
    C1 = C1 - 0.4068 * Math.sin(Mpr * dr) + 0.0161 * Math.sin(dr * 2 * Mpr);
    C1 = C1 - 0.0004 * Math.sin(dr * 3 * Mpr);
    C1 = C1 + 0.0104 * Math.sin(dr * 2 * F) - 0.0051 * Math.sin(dr * (M + Mpr));
    C1 = C1 - 0.0074 * Math.sin(dr * (M - Mpr)) + 0.0004 * Math.sin(dr * (2 * F + M));
    C1 = C1 - 0.0004 * Math.sin(dr * (2 * F - M)) - 0.0006 * Math.sin(dr * (2 * F + Mpr));
    C1 = C1 + 0.0010 * Math.sin(dr * (2 * F - Mpr)) + 0.0005 * Math.sin(dr * (2 * Mpr + M));
    var deltat;
    if (T < -11) {
        deltat = 0.001 + 0.000839 * T + 0.0002261 * T2 - 0.00000845 * T3 - 0.000000081 * T * T3;
    } else {
        deltat = -0.000278 + 0.000265 * T + 0.000262 * T2;
    }
    return Jd1 + C1 - deltat;
}

function sunLongitude(jdn) {
    var T = (jdn - 2451545.0) / 36525;
    var T2 = T * T;
    var dr = PI / 180;
    var M = 357.52910 + 35999.05030 * T - 0.0001559 * T2 - 0.00000048 * T * T2;
    var L0 = 280.46645 + 36000.76983 * T + 0.0003032 * T2;
    var DL = (1.914600 - 0.004817 * T - 0.000014 * T2) * Math.sin(dr * M);
    DL = DL + (0.019993 - 0.000101 * T) * Math.sin(dr * 2 * M) + 0.000290 * Math.sin(dr * 3 * M);
    var L = L0 + DL;
    L = L * dr;
    L = L - PI * 2 * (INT(L / (PI * 2)));
    return L;
}

function getSunLongitude(dayNumber, timeZone) {
    return INT(sunLongitude(dayNumber - 0.5 - timeZone / 24.0) / PI * 6);
}

function getNewMoonDay(k, timeZone) {
    return INT(newMoon(k) + 0.5 + timeZone / 24.0);
}

function getLunarMonth11(yy, timeZone) {
    var off = jdFromDate(31, 12, yy) - 2415021;
    var k = INT(off / 29.530588853);
    var nm = getNewMoonDay(k, timeZone);
    var sunLong = getSunLongitude(nm, timeZone);
    if (sunLong >= 9) {
        nm = getNewMoonDay(k - 1, timeZone);
    }
    return nm;
}

function getLeapMonthOffset(a11, timeZone) {
    var k = INT((a11 - 2415021.076998695) / 29.530588853 + 0.5);
    var last = 0;
    var i = 1;
    var arc = getSunLongitude(getNewMoonDay(k + i, timeZone), timeZone);
    do {
        last = arc;
        i++;
        arc = getSunLongitude(getNewMoonDay(k + i, timeZone), timeZone);
    } while (arc !== last && i < 14);
    return i - 1;
}

function convertSolar2Lunar(dd, mm, yy) {
    var dayNumber = jdFromDate(dd, mm, yy);
    var k = INT((dayNumber - 2415021.076998695) / 29.530588853);
    var monthStart = getNewMoonDay(k + 1, VIETNAM_TZ);
    if (monthStart > dayNumber) {
        monthStart = getNewMoonDay(k, VIETNAM_TZ);
    }
    var a11 = getLunarMonth11(yy, VIETNAM_TZ);
    var b11 = a11;
    var lunarYear;
    if (a11 >= monthStart) {
        lunarYear = yy;
        a11 = getLunarMonth11(yy - 1, VIETNAM_TZ);
    } else {
        lunarYear = yy + 1;
        b11 = getLunarMonth11(yy + 1, VIETNAM_TZ);
    }
    var lunarDay = dayNumber - monthStart + 1;
    var diff = INT((monthStart - a11) / 29);
    var lunarLeap = false;
    var lunarMonth = diff + 11;
    if (b11 - a11 > 365) {
        var leapMonthDiff = getLeapMonthOffset(a11, VIETNAM_TZ);
        if (diff >= leapMonthDiff) {
            lunarMonth = diff + 10;
            if (diff === leapMonthDiff) {
                lunarLeap = true;
            }
        }
    }
    if (lunarMonth > 12) {
        lunarMonth = lunarMonth - 12;
    }
    if (lunarMonth >= 11 && diff < 4) {
        lunarYear -= 1;
    }
    return {
        day: lunarDay,
        month: lunarMonth,
        year: lunarYear,
        leap: lunarLeap,
        jd: dayNumber
    };
}

function getCanChiYear(lunarYear) {
    var canIndex = (lunarYear + 6) % 10;
    var chiIndex = (lunarYear + 8) % 12;
    if (canIndex < 0) canIndex += 10;
    if (chiIndex < 0) chiIndex += 12;
    return CAN[canIndex] + " " + CHI[chiIndex];
}

function formatLunarShort(lunar, lang) {
    if (lunar.day === 1) {
        var leapMark = lunar.leap ? (lang === "vi" ? "N" : "L") : "";
        return lunar.day + "/" + lunar.month + leapMark;
    }
    return String(lunar.day);
}

function formatLunarFull(lunar, lang) {
    if (lang === "vi") {
        var monthName = LUNAR_MONTH_NAMES_VI[lunar.month] || ("Tháng " + lunar.month);
        if (lunar.leap) {
            monthName += " (nhuận)";
        }
        return "Ngày " + lunar.day + " " + monthName + " năm " + getCanChiYear(lunar.year);
    }
    var leapText = lunar.leap ? " (Leap)" : "";
    return "Day " + lunar.day + ", Month " + lunar.month + leapText + " (" + getCanChiYear(lunar.year) + ")";
}

var SOLAR_HOLIDAYS = {
    "1-1":   { vi: "Tết Dương lịch", en: "New Year's Day", isPublicHoliday: true },
    "3-2":   { vi: "Ngày thành lập Đảng CSVN", en: "Communist Party of Vietnam Founding Day", isPublicHoliday: false },
    "27-2":  { vi: "Ngày Thầy thuốc Việt Nam", en: "Vietnamese Doctors' Day", isPublicHoliday: false },
    "8-3":   { vi: "Ngày Quốc tế Phụ nữ", en: "International Women's Day", isPublicHoliday: false },
    "26-3":  { vi: "Ngày thành lập Đoàn TNCS HCM", en: "Ho Chi Minh Youth Union Day", isPublicHoliday: false },
    "30-4":  { vi: "Ngày Giải phóng miền Nam, thống nhất đất nước", en: "Reunification Day", isPublicHoliday: true },
    "1-5":   { vi: "Ngày Quốc tế Lao động", en: "International Labor Day", isPublicHoliday: true },
    "19-5":  { vi: "Ngày sinh Chủ tịch Hồ Chí Minh", en: "President Ho Chi Minh's Birthday", isPublicHoliday: false },
    "1-6":   { vi: "Ngày Quốc tế Thiếu nhi", en: "International Children's Day", isPublicHoliday: false },
    "28-6":  { vi: "Ngày Gia đình Việt Nam", en: "Vietnamese Family Day", isPublicHoliday: false },
    "27-7":  { vi: "Ngày Thương binh - Liệt sĩ", en: "War Invalids and Martyrs Day", isPublicHoliday: false },
    "19-8":  { vi: "Cách mạng Tháng Tám thành công", en: "August Revolution Commemoration Day", isPublicHoliday: false },
    "2-9":   { vi: "Ngày Quốc khánh Việt Nam", en: "Vietnam National Day", isPublicHoliday: true },
    "10-10": { vi: "Ngày Giải phóng Thủ đô", en: "Capital Liberation Day", isPublicHoliday: false },
    "20-10": { vi: "Ngày Phụ nữ Việt Nam", en: "Vietnamese Women's Day", isPublicHoliday: false },
    "20-11": { vi: "Ngày Nhà giáo Việt Nam", en: "Vietnamese Teachers' Day", isPublicHoliday: false },
    "22-12": { vi: "Ngày thành lập QĐND Việt Nam", en: "Vietnam People's Army Founding Day", isPublicHoliday: false },
    "24-12": { vi: "Lễ Giáng sinh (Noel)", en: "Christmas Eve", isPublicHoliday: false }
};

var LUNAR_HOLIDAYS = {
    "1-1":   { vi: "Mùng 1 Tết Nguyên Đán", en: "Tết Day 1 (Lunar New Year)", isPublicHoliday: true },
    "2-1":   { vi: "Mùng 2 Tết Nguyên Đán", en: "Tết Day 2 (Lunar New Year)", isPublicHoliday: true },
    "3-1":   { vi: "Mùng 3 Tết Nguyên Đán", en: "Tết Day 3 (Lunar New Year)", isPublicHoliday: true },
    "4-1":   { vi: "Mùng 4 Tết Nguyên Đán", en: "Tết Day 4 (Lunar New Year)", isPublicHoliday: false },
    "5-1":   { vi: "Mùng 5 Tết Nguyên Đán", en: "Tết Day 5 (Lunar New Year)", isPublicHoliday: false },
    "15-1":  { vi: "Tết Nguyên Tiêu (Rằm tháng Giêng)", en: "Lantern Festival (First Full Moon)", isPublicHoliday: false },
    "3-3":   { vi: "Tết Hàn Thực", en: "Cold Food Festival (Tết Hàn Thực)", isPublicHoliday: false },
    "10-3":  { vi: "Giỗ Tổ Hùng Vương", en: "Hung Kings' Commemoration Day", isPublicHoliday: true },
    "15-4":  { vi: "Lễ Phật Đản", en: "Vesak (Buddha's Birthday)", isPublicHoliday: false },
    "5-5":   { vi: "Tết Đoan Ngọ", en: "Mid-Year Festival (Tết Đoan Ngọ)", isPublicHoliday: false },
    "15-7":  { vi: "Lễ Vu Lan (Rằm tháng Bảy)", en: "Vu Lan Festival (Ghost Festival)", isPublicHoliday: false },
    "15-8":  { vi: "Tết Trung Thu", en: "Mid-Autumn Festival (Tết Trung Thu)", isPublicHoliday: false },
    "23-12": { vi: "Tiễn Ông Công Ông Táo", en: "Kitchen Gods' Day (Ông Công Ông Táo)", isPublicHoliday: false }
};

function getVietnamHolidays(solarDay, solarMonth, solarYear, precomputedLunar, lang) {
    var l = (lang === "vi") ? "vi" : "en";
    var holidays = [];
    var lunar = precomputedLunar || convertSolar2Lunar(solarDay, solarMonth, solarYear);

    var solarKey = solarDay + "-" + solarMonth;
    if (SOLAR_HOLIDAYS[solarKey]) {
        holidays.push({
            name: SOLAR_HOLIDAYS[solarKey][l],
            isPublicHoliday: SOLAR_HOLIDAYS[solarKey].isPublicHoliday,
            calendar: "solar"
        });
    }

    if (!lunar.leap) {
        var lunarKey = lunar.day + "-" + lunar.month;
        if (LUNAR_HOLIDAYS[lunarKey]) {
            holidays.push({
                name: LUNAR_HOLIDAYS[lunarKey][l],
                isPublicHoliday: LUNAR_HOLIDAYS[lunarKey].isPublicHoliday,
                calendar: "lunar"
            });
        }

        // Check Giao Thua (Lunar New Year's Eve: handles both 29-day and 30-day lunar Decembers)
        if (lunar.month === 12 && lunar.day >= 29) {
            var nextDate = new Date(solarYear, solarMonth - 1, solarDay + 1);
            var nextLunar = convertSolar2Lunar(nextDate.getDate(), nextDate.getMonth() + 1, nextDate.getFullYear());
            if (!nextLunar.leap && nextLunar.month === 1 && nextLunar.day === 1) {
                holidays.push({
                    name: l === "vi" ? "Đêm Giao thừa (Tất niên)" : "Lunar New Year's Eve (Giao thừa)",
                    isPublicHoliday: true,
                    calendar: "lunar"
                });
            }
        }
    }

    return holidays;
}

function getISOWeekNumber(year, month, day) {
    var d = new Date(Date.UTC(year, month - 1, day));
    var dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    var yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
}

function buildMonthGrid(year, month, firstDayOfWeek, todayParts, showVietnamHolidays, lang) {
    var l = (lang === "vi") ? "vi" : "en";
    var startDow = (firstDayOfWeek >= 0 && firstDayOfWeek <= 6) ? firstDayOfWeek : 1;
    var firstDate = new Date(year, month - 1, 1);
    var firstDateDow = firstDate.getDay();
    var leadingDays = (firstDateDow - startDow + 7) % 7;

    var cells = [];
    var monthHolidays = [];
    var lunarSuffix = (l === "vi") ? " ÂL" : " Lunar";

    for (var i = 0; i < 42; i++) {
        var d = new Date(year, month - 1, 1 - leadingDays + i);
        var cellYear = d.getFullYear();
        var cellMonth = d.getMonth() + 1;
        var cellDay = d.getDate();
        var cellDow = d.getDay();
        var isCurrentMonth = (cellYear === year && cellMonth === month);
        var isToday = (
            todayParts &&
            cellYear === todayParts.year &&
            cellMonth === todayParts.month &&
            cellDay === todayParts.day
        );
        var lunar = convertSolar2Lunar(cellDay, cellMonth, cellYear);
        var holidays = showVietnamHolidays ? getVietnamHolidays(cellDay, cellMonth, cellYear, lunar, l) : [];
        var hasPublicHoliday = false;
        for (var h = 0; h < holidays.length; h++) {
            if (holidays[h].isPublicHoliday) {
                hasPublicHoliday = true;
            }
            if (isCurrentMonth) {
                var leapMark = lunar.leap ? (l === "vi" ? "N" : "L") : "";
                monthHolidays.push({
                    day: cellDay,
                    month: cellMonth,
                    year: cellYear,
                    name: holidays[h].name,
                    isPublicHoliday: holidays[h].isPublicHoliday,
                    calendar: holidays[h].calendar,
                    lunarText: lunar.day + "/" + lunar.month + leapMark + lunarSuffix
                });
            }
        }

        cells.push({
            year: cellYear,
            month: cellMonth,
            day: cellDay,
            weekday: cellDow,
            isCurrentMonth: isCurrentMonth,
            isToday: isToday,
            isWeekend: (cellDow === 0 || cellDow === 6),
            lunarDay: lunar.day,
            lunarMonth: lunar.month,
            lunarYear: lunar.year,
            lunarLeap: lunar.leap,
            lunarShort: formatLunarShort(lunar, l),
            lunarFull: formatLunarFull(lunar, l),
            holidays: holidays,
            hasHoliday: holidays.length > 0,
            hasPublicHoliday: hasPublicHoliday
        });
    }

    var weekNumbers = [];
    for (var row = 0; row < 6; row++) {
        var c = cells[row * 7];
        weekNumbers.push(getISOWeekNumber(c.year, c.month, c.day));
    }

    return {
        cells: cells,
        monthHolidays: monthHolidays,
        weekNumbers: weekNumbers
    };
}
