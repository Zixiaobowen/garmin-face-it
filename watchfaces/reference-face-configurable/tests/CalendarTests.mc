import Toybox.Test;

(:test)
class CalendarTestDate {
    var year;
    var month;
    var day;
    function initialize(y, m, d) { year = y; month = m; day = d; }
}

(:test)
function calendarCivilDays(logger) {
    Test.assertEqual(FaceCalendar.dayNumber(new CalendarTestDate(1970, 1, 1)), 0);
    Test.assertEqual(FaceCalendar.dayNumber(new CalendarTestDate(2000, 1, 1)), 10957);
    Test.assertEqual(FaceCalendar.dayNumber(new CalendarTestDate(2000, 3, 1))
        - FaceCalendar.dayNumber(new CalendarTestDate(2000, 2, 28)), 2);
    Test.assertEqual(FaceCalendar.dayNumber(new CalendarTestDate(2100, 3, 1))
        - FaceCalendar.dayNumber(new CalendarTestDate(2100, 2, 28)), 1);
    Test.assertEqual(FaceCalendar.dayNumber(new CalendarTestDate(2026, 1, 1))
        - FaceCalendar.dayNumber(new CalendarTestDate(2025, 12, 31)), 1);
    return true;
}

(:test)
function calendarWeekdays(logger) {
    Test.assertEqual(FaceCalendar.weekday(1), "周日");
    Test.assertEqual(FaceCalendar.weekday(2), "周一");
    Test.assertEqual(FaceCalendar.weekday(7), "周六");
    Test.assert(FaceCalendar.weekday(0) == null);
    Test.assert(FaceCalendar.weekday(8) == null);
    Test.assert(FaceCalendar.weekday(null) == null);
    return true;
}

(:test)
function calendarLunarNewYears(logger) {
    Test.assertEqual(FaceCalendar.lunar(new CalendarTestDate(2000, 2, 5)), "正月初一");
    Test.assertEqual(FaceCalendar.lunar(new CalendarTestDate(2024, 2, 9)), "腊月三十");
    Test.assertEqual(FaceCalendar.lunar(new CalendarTestDate(2024, 2, 10)), "正月初一");
    Test.assertEqual(FaceCalendar.lunar(new CalendarTestDate(2025, 1, 28)), "腊月廿九");
    Test.assertEqual(FaceCalendar.lunar(new CalendarTestDate(2025, 1, 29)), "正月初一");
    Test.assertEqual(FaceCalendar.lunar(new CalendarTestDate(2026, 2, 17)), "正月初一");
    return true;
}

(:test)
function calendarLunarLeapMonths(logger) {
    Test.assertEqual(FaceCalendar.lunar(new CalendarTestDate(2023, 3, 21)), "二月三十");
    Test.assertEqual(FaceCalendar.lunar(new CalendarTestDate(2023, 3, 22)), "闰二月初一");
    Test.assertEqual(FaceCalendar.lunar(new CalendarTestDate(2023, 4, 19)), "闰二月廿九");
    Test.assertEqual(FaceCalendar.lunar(new CalendarTestDate(2023, 4, 20)), "三月初一");
    Test.assertEqual(FaceCalendar.lunar(new CalendarTestDate(2020, 5, 23)), "闰四月初一");
    return true;
}

(:test)
function calendarLunarCoverage(logger) {
    Test.assert(FaceCalendar.lunar(new CalendarTestDate(1999, 12, 31)) == null);
    Test.assertEqual(FaceCalendar.lunar(new CalendarTestDate(2000, 1, 1)), "冬月廿五");
    Test.assert(FaceCalendar.lunar(new CalendarTestDate(2099, 12, 31)) != null);
    Test.assert(FaceCalendar.lunar(new CalendarTestDate(2100, 1, 1)) == null);
    return true;
}

(:test)
function calendarVo2Thresholds(logger) {
    // Independent official table samples span both genders and all age decades.
    var maleSuperior = [55.4, 54.0, 52.5, 48.9, 45.7, 42.1];
    var femaleSuperior = [49.6, 47.4, 45.3, 41.1, 37.8, 36.7];
    for (var decade = 0; decade < 6; decade += 1) {
        var birthYear = 2026 - (20 + decade * 10);
        Test.assertEqual(FaceCalendar.vo2Rating(maleSuperior[decade], birthYear, 1, 2026), "卓越");
        Test.assertEqual(FaceCalendar.vo2Rating(maleSuperior[decade] - 0.1, birthYear, 1, 2026), "优秀");
        Test.assertEqual(FaceCalendar.vo2Rating(femaleSuperior[decade], birthYear, 0, 2026), "卓越");
        Test.assertEqual(FaceCalendar.vo2Rating(femaleSuperior[decade] - 0.1, birthYear, 0, 2026), "优秀");
    }
    Test.assertEqual(FaceCalendar.vo2Rating(51.1, 2006, 1, 2026), "优秀");
    Test.assertEqual(FaceCalendar.vo2Rating(51.0, 2006, 1, 2026), "良好");
    Test.assertEqual(FaceCalendar.vo2Rating(45.4, 2006, 1, 2026), "良好");
    Test.assertEqual(FaceCalendar.vo2Rating(45.3, 2006, 1, 2026), "一般");
    Test.assertEqual(FaceCalendar.vo2Rating(41.7, 2006, 1, 2026), "一般");
    Test.assertEqual(FaceCalendar.vo2Rating(41.6, 2006, 1, 2026), "较低");
    Test.assertEqual(FaceCalendar.vo2Rating(30.9, 1947, 0, 2026), "优秀");
    Test.assertEqual(FaceCalendar.vo2Rating(30.8, 1947, 0, 2026), "良好");
    Test.assertEqual(FaceCalendar.vo2Rating(28.1, 1947, 0, 2026), "良好");
    Test.assertEqual(FaceCalendar.vo2Rating(28.0, 1947, 0, 2026), "一般");
    Test.assertEqual(FaceCalendar.vo2Rating(25.9, 1947, 0, 2026), "一般");
    Test.assertEqual(FaceCalendar.vo2Rating(25.8, 1947, 0, 2026), "较低");
    // A single year crossing into the next official decade changes the grade.
    Test.assertEqual(FaceCalendar.vo2Rating(54.0, 1997, 1, 2026), "优秀");
    Test.assertEqual(FaceCalendar.vo2Rating(54.0, 1996, 1, 2026), "卓越");
    return true;
}

(:test)
function calendarVo2MissingAndAgeRange(logger) {
    Test.assert(FaceCalendar.vo2Rating(null, 2000, 1, 2026) == null);
    Test.assert(FaceCalendar.vo2Rating(50, null, 1, 2026) == null);
    Test.assert(FaceCalendar.vo2Rating(50, 2000, null, 2026) == null);
    Test.assert(FaceCalendar.vo2Rating(50, 2000, 1, null) == null);
    Test.assert(FaceCalendar.vo2Rating(50, 2000, 2, 2026) == null);
    Test.assert(FaceCalendar.vo2Rating(50, 2000, -1, 2026) == null);
    Test.assert(FaceCalendar.vo2Rating(50, 2007, 1, 2026) == null);
    Test.assert(FaceCalendar.vo2Rating(50, 1946, 1, 2026) == null);
    Test.assert(FaceCalendar.vo2Rating(0, 2000, 1, 2026) == null);
    Test.assert(FaceCalendar.vo2Rating(-1, 2000, 1, 2026) == null);
    return true;
}
