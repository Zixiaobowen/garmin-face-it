import Toybox.Lang;
import Toybox.Test;

(:test)
function midnightAndNoon(logger as Test.Logger) as Boolean {
    Test.assertEqual(FaceTime.format(0, 0, false), "12:00");
    Test.assertEqual(FaceTime.period(0, false), "AM");
    Test.assertEqual(FaceTime.format(12, 0, false), "12:00");
    Test.assertEqual(FaceTime.period(12, false), "PM");
    return true;
}

(:test)
function twentyFourHourClock(logger as Test.Logger) as Boolean {
    Test.assertEqual(FaceTime.format(0, 0, true), "00:00");
    Test.assertEqual(FaceTime.format(23, 59, true), "23:59");
    Test.assertEqual(FaceTime.period(23, true), "");
    return true;
}

(:test)
function afternoonAndMinutePadding(logger as Test.Logger) as Boolean {
    Test.assertEqual(FaceTime.format(13, 5, false), "01:05");
    Test.assertEqual(FaceTime.period(13, false), "PM");
    Test.assertEqual(FaceTime.format(23, 59, false), "11:59");
    return true;
}
