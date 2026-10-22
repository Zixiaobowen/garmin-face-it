// Pure date and VO2 helpers; compatible with Connect IQ API 1.4.
module FaceCalendar {
    // Days since 1970-01-01, using the civil-date algorithm (no timezone arithmetic).
    function dayNumber(info) {
        var y = info.year;
        var m = info.month;
        if (m <= 2) { y -= 1; }
        var era = (y / 400).toNumber();
        var yearOfEra = y - era * 400;
        var shiftedMonth = m + (m > 2 ? -3 : 9);
        var dayOfYear = ((153 * shiftedMonth + 2) / 5).toNumber() + info.day - 1;
        return era * 146097 + yearOfEra * 365 + (yearOfEra / 4).toNumber()
            - (yearOfEra / 100).toNumber() + dayOfYear - 719468;
    }

    var WEEKDAYS = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];
    var MONTHS = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "冬", "腊"];
    var DIGITS = ["一", "二", "三", "四", "五", "六", "七", "八", "九"];

    function weekday(dayOfWeek) {
        if (dayOfWeek == null || dayOfWeek < 1 || dayOfWeek > 7) { return null; }
        return WEEKDAYS[dayOfWeek - 1];
    }

    function lunar(info) {
        if (info.year < 2000 || info.year > 2099) { return null; }
        var day = dayNumber(info);
        // STARTS includes lunar 1999, which contains Gregorian 2000-01-01.
        var low = 0;
        var high = LunarData.STARTS.size() - 1;
        while (low < high) {
            var middle = ((low + high + 1) / 2).toNumber();
            if (LunarData.STARTS[middle] <= day) { low = middle; }
            else { high = middle - 1; }
        }
        var packed = LunarData.YEARS[low];
        var leapMonth = packed >> 13;
        var remaining = day - LunarData.STARTS[low];
        var slot = 0;
        var length = 29 + ((packed >> slot) & 1);
        while (remaining >= length) {
            remaining -= length;
            slot += 1;
            length = 29 + ((packed >> slot) & 1);
        }
        var isLeap = leapMonth > 0 && slot == leapMonth;
        var month = slot + 1;
        if (leapMonth > 0 && slot >= leapMonth) { month -= 1; }
        var prefix = (isLeap ? "闰" : "") + MONTHS[month - 1] + "月";
        var lunarDay = remaining + 1;
        if (lunarDay < 10) { return prefix + "初" + DIGITS[lunarDay - 1]; }
        if (lunarDay == 10) { return prefix + "初十"; }
        if (lunarDay < 20) { return prefix + "十" + DIGITS[lunarDay - 11]; }
        if (lunarDay == 20) { return prefix + "二十"; }
        if (lunarDay < 30) { return prefix + "廿" + DIGITS[lunarDay - 21]; }
        return prefix + "三十";
    }

    // Each age decade has Superior / Excellent / Good / Fair minimums.
    // Garmin Venu Sq manual, VO2 Max. Standard Ratings:
    // https://www8.garmin.com/manuals-apac/webhelp/venusq/EN-SG/GUID-983180E8-9BB5-4159-88E2-443D3CC59289-7301.html
    var MALE = [55.4, 51.1, 45.4, 41.7, 54.0, 48.3, 44.0, 40.5,
        52.5, 46.4, 42.4, 38.5, 48.9, 43.4, 39.2, 35.6,
        45.7, 39.5, 35.5, 32.3, 42.1, 36.7, 32.3, 29.4];
    var FEMALE = [49.6, 43.9, 39.5, 36.1, 47.4, 42.4, 37.8, 34.4,
        45.3, 39.7, 36.3, 33.0, 41.1, 36.7, 33.0, 30.1,
        37.8, 33.0, 30.0, 27.5, 36.7, 30.9, 28.1, 25.9];
    var RATINGS = ["卓越", "优秀", "良好", "一般", "较低"];

    // Age is estimated from birth year; the profile does not expose a birthday.
    function vo2Rating(value, birthYear, gender, currentYear) {
        if (value == null || birthYear == null || gender == null || currentYear == null) { return null; }
        if (!(value > 0) || (gender != 0 && gender != 1)) { return null; }
        var age = currentYear - birthYear;
        if (age < 20 || age > 79) { return null; }
        var offset = ((age - 20) / 10).toNumber() * 4;
        var thresholds = gender == 1 ? MALE : FEMALE;
        for (var i = 0; i < 4; i += 1) {
            if (value >= thresholds[offset + i]) { return RATINGS[i]; }
        }
        return RATINGS[4];
    }
}
