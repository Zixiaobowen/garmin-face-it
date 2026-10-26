import Toybox.Test;

(:test)
class DataTestIterator {
    var rows;
    var index = 0;
    function initialize(values) { rows = values; }
    function next() {
        if (index == rows.size()) { return null; }
        var row = rows[index];
        index += 1;
        return row;
    }
}

(:test)
class DataTestSample {
    var when;
    var heartRate;
    var data;
    function initialize(seconds, value) {
        when = seconds == null ? null : new Toybox.Time.Moment(seconds);
        heartRate = value;
        data = value;
    }
}

(:test)
class DataTestWeather {
    var observationTime;
    var temperature = 12;
    var feelsLikeTemperature = 10;
    var precipitationChance = 40;
    function initialize(seconds) {
        observationTime = seconds == null ? null : new Toybox.Time.Moment(seconds);
    }
}

(:test)
class DataTestActivity {
    var type;
    var startTime;
    var distance;
    function initialize(sport, seconds, metres) {
        type = sport;
        startTime = seconds == null ? null : new Toybox.Time.Moment(seconds);
        distance = metres;
    }
}

(:test)
class DataTestProfile {
    var vo2maxRunning = 50;
    var birthYear = 1990;
    var gender = 1;
}

(:test)
class DataTestInfo {
    var steps = 0;
    var timeToRecovery = 12;
}

// Replace only SDK reads. Cache transitions and filtering use production code.
(:test)
class DataTestSource extends FaceData {
    var minuteReads = 0;
    var profileReads = 0;
    var zoneReads = 0;
    var historyReads = 0;
    var heartRows = null;
    var bodyRows = null;
    var activityRows = null;
    var conditions = null;
    var profile = null;
    var info = null;
    var thresholds = null;
    var failHistory = false;

    function initialize() { FaceData.initialize(); }
    function detectCapabilities() {
        supportsHr = true;
        supportsSteps = true;
        supportsRecovery = true;
        supportsVo2 = true;
        supportsBody = true;
        supportsWeather = true;
        supportsHistory = true;
        supportsWeekly = true;
        supportsSunrise = true;
    }
    function readBattery() { minuteReads += 1; battery = 75; }
    function readComplications() { weeklyMeters = 12345; sunrise = 21600; }
    function heartRateHistory() {
        return heartRows == null ? null : new DataTestIterator(heartRows);
    }
    function bodyBatteryHistory() {
        return bodyRows == null ? null : new DataTestIterator(bodyRows);
    }
    function weatherConditions() { return conditions; }
    function activityInfo() { return info; }
    function userProfile() { profileReads += 1; return profile; }
    function heartRateZones() { zoneReads += 1; return thresholds; }
    function activityHistory() {
        historyReads += 1;
        if (failHistory) { throw new Toybox.Lang.Exception(); }
        return activityRows == null ? null : new DataTestIterator(activityRows);
    }
}

(:test)
function dataCacheCadence(logger) {
    var source = new DataTestSource();
    var start = 1800000000;
    source.profile = new DataTestProfile();
    source.thresholds = [90, 110, 130, 150, 170, 190];
    source.refresh(new Toybox.Time.Moment(start));
    Test.assertEqual(source.minuteReads, 1);
    Test.assertEqual(source.profileReads, 1);
    Test.assertEqual(source.zoneReads, 1);
    Test.assertEqual(source.historyReads, 1);
    Test.assertEqual(source.vo2, 50);
    source.refresh(new Toybox.Time.Moment(start + 59));
    Test.assertEqual(source.minuteReads, 1);
    source.refresh(new Toybox.Time.Moment(start + 60));
    Test.assertEqual(source.minuteReads, 2);
    Test.assertEqual(source.profileReads, 1);
    Test.assertEqual(source.historyReads, 1);
    source.refresh(new Toybox.Time.Moment(start + 299));
    Test.assertEqual(source.historyReads, 1);
    source.refresh(new Toybox.Time.Moment(start + 300));
    Test.assertEqual(source.historyReads, 2);
    source.refresh(new Toybox.Time.Moment(start + 899));
    Test.assertEqual(source.profileReads, 1);
    source.profile = null;
    source.thresholds = null;
    source.refresh(new Toybox.Time.Moment(start + 900));
    Test.assertEqual(source.profileReads, 2);
    Test.assertEqual(source.zoneReads, 2);
    Test.assert(source.vo2 == null);
    Test.assert(source.zones == null);
    Test.assert(source.supportsMetric(FaceSettings.VO2));
    return true;
}

(:test)
function dataHistoryToggleAndRollback(logger) {
    var source = new DataTestSource();
    var start = 1800000000;
    source.activityRows = [new DataTestActivity(Toybox.Activity.SPORT_RUNNING, start, 1000)];
    source.historyEnabled = false;
    source.refresh(new Toybox.Time.Moment(start));
    Test.assertEqual(source.historyReads, 0);
    Test.assert(source.supportsHistory);
    Test.assert(source.supportsMetric(FaceSettings.WEEKLY_RUN));
    Test.assertEqual(source.weeklyMeters, 12345);
    source.historyEnabled = true;
    source.refresh(new Toybox.Time.Moment(start));
    Test.assertEqual(source.historyReads, 1);
    Test.assertEqual(source.runs[6], 1000);
    source.historyEnabled = false;
    source.refresh(new Toybox.Time.Moment(start));
    Test.assert(source.runs == null);
    source.historyEnabled = true;
    source.refresh(new Toybox.Time.Moment(start));
    Test.assertEqual(source.historyReads, 2);
    Test.assertEqual(source.runs[6], 1000);
    source.refresh(new Toybox.Time.Moment(start + 130));
    source.refresh(new Toybox.Time.Moment(start + 129));
    Test.assertEqual(source.minuteReads, 3);
    Test.assertEqual(source.profileReads, 2);
    Test.assertEqual(source.historyReads, 3);
    source.refresh(new Toybox.Time.Moment(start + 189));
    Test.assertEqual(source.minuteReads, 4);
    Test.assertEqual(source.historyReads, 3);
    return true;
}

(:test)
function dataHistoryLocalDateChange(logger) {
    var source = new DataTestSource();
    // Find the local date boundary, including the simulator's time zone.
    var midnight = 1800000000;
    var initialDay = FaceCalendar.dayNumber(Toybox.Time.Gregorian.info(
        new Toybox.Time.Moment(midnight), Toybox.Time.FORMAT_SHORT));
    while (FaceCalendar.dayNumber(Toybox.Time.Gregorian.info(
        new Toybox.Time.Moment(midnight), Toybox.Time.FORMAT_SHORT)) == initialDay) {
        midnight += 60;
    }
    source.activityRows = [new DataTestActivity(Toybox.Activity.SPORT_RUNNING, midnight - 60, 2500)];
    source.refresh(new Toybox.Time.Moment(midnight - 60));
    Test.assertEqual(source.runs[6], 2500);
    source.refresh(new Toybox.Time.Moment(midnight));
    Test.assertEqual(source.historyReads, 2);
    Test.assertEqual(source.runs[5], 2500);
    Test.assertEqual(source.runs[6], 0);
    return true;
}

(:test)
function dataFailedReadIsNotCached(logger) {
    var source = new DataTestSource();
    var now = new Toybox.Time.Moment(1800000000);
    source.failHistory = true;
    var propagated = false;
    try { source.refresh(now); }
    catch (error instanceof Toybox.Lang.Exception) { propagated = true; }
    Test.assert(propagated);
    source.failHistory = false;
    source.refresh(now);
    Test.assertEqual(source.minuteReads, 2);
    Test.assertEqual(source.historyReads, 2);
    source.refresh(now);
    Test.assertEqual(source.minuteReads, 2);
    Test.assertEqual(source.historyReads, 2);
    return true;
}

(:test)
function dataHeartRateAndBodyBoundaries(logger) {
    var source = new DataTestSource();
    var now = 1800000000;
    source.heartRows = [new DataTestSample(now + 1, 80),
        new DataTestSample(now, 255), new DataTestSample(now, 0),
        new DataTestSample(now, null), new DataTestSample(null, 75),
        new DataTestSample(now - 301, 90), new DataTestSample(now - 300, 65)];
    source.readHeartRate(now);
    Test.assertEqual(source.hr, 65);
    Test.assertEqual(source.hrAgeSeconds, 300);
    source.readHeartRate(now + 1);
    Test.assertEqual(source.hr, 80);
    source.heartRows = [new DataTestSample(now - 301, 65)];
    source.readHeartRate(now);
    Test.assert(source.hr == null);
    Test.assert(source.hrAgeSeconds == null);
    Test.assert(source.supportsMetric(FaceSettings.HEART_RATE));
    source.bodyRows = [new DataTestSample(now + 1, 80),
        new DataTestSample(now, -1), new DataTestSample(now, 101),
        new DataTestSample(now - 1801, 60), new DataTestSample(now - 1800, 0)];
    source.readBodyBattery(now);
    Test.assertEqual(source.body, 0);
    Test.assertEqual(source.bodyAgeSeconds, 1800);
    source.bodyRows = [new DataTestSample(now - 1801, 60)];
    source.readBodyBattery(now);
    Test.assert(source.body == null);
    Test.assert(source.bodyAgeSeconds == null);
    Test.assert(source.supportsMetric(FaceSettings.BODY_BATTERY));
    return true;
}

(:test)
function dataWeatherBoundaries(logger) {
    var source = new DataTestSource();
    var now = 1800000000;
    source.conditions = new DataTestWeather(now - 10800);
    source.readWeather(now);
    Test.assertEqual(source.temperature, 12);
    Test.assertEqual(source.feels, 10);
    Test.assertEqual(source.rain, 40);
    Test.assertEqual(source.weatherAgeSeconds, 10800);
    Test.assert(!source.weatherStale);
    source.readWeather(now + 1);
    Test.assert(source.temperature == null);
    Test.assert(source.feels == null);
    Test.assert(source.rain == null);
    Test.assert(source.weatherStale);
    Test.assertEqual(source.weatherAgeSeconds, 10801);
    source.conditions = new DataTestWeather(now + 1);
    source.readWeather(now);
    Test.assert(source.temperature == null);
    Test.assert(source.weatherAgeSeconds == null);
    Test.assert(!source.weatherStale);
    source.conditions = new DataTestWeather(null);
    source.readWeather(now);
    Test.assert(source.temperature == null);
    source.conditions = null;
    source.readWeather(now);
    Test.assert(source.supportsMetric(FaceSettings.WEATHER));
    Test.assert(source.supportsMetric(FaceSettings.RAIN));
    return true;
}

(:test)
function dataCapabilityAndZeroValues(logger) {
    var source = new DataTestSource();
    source.readActivityInfo();
    source.readProfile(2027);
    Test.assert(source.steps == null);
    Test.assert(source.recovery == null);
    Test.assert(source.vo2 == null);
    Test.assert(source.supportsMetric(FaceSettings.STEPS));
    Test.assert(source.supportsMetric(FaceSettings.RECOVERY));
    Test.assert(source.supportsMetric(FaceSettings.VO2));
    source.info = new DataTestInfo();
    source.readActivityInfo();
    Test.assertEqual(source.steps, 0);
    Test.assertEqual(source.recovery, 12);
    source.info = null;
    source.readActivityInfo();
    Test.assert(source.steps == null);
    Test.assert(source.recovery == null);
    Test.assert(source.supportsMetric(FaceSettings.STEPS));
    source.supportsSteps = false;
    Test.assert(!source.supportsMetric(FaceSettings.STEPS));
    Test.assert(!source.supportsMetric(FaceSettings.AUTO));
    Test.assert(!source.supportsMetric(FaceSettings.NONE));
    Test.assert(!source.supportsMetric(99));
    return true;
}

(:test)
function dataRunHistoryFilteringAndLocalBuckets(logger) {
    var source = new DataTestSource();
    var now = 1800000000;
    var today = FaceCalendar.dayNumber(Toybox.Time.Gregorian.info(
        new Toybox.Time.Moment(now), Toybox.Time.FORMAT_SHORT));
    var running = Toybox.Activity.SPORT_RUNNING;
    source.activityRows = [new DataTestActivity(running, now - 10 * 86400, 9000),
        new DataTestActivity(Toybox.Activity.SPORT_CYCLING, now, 4000),
        new DataTestActivity(running, now, -1), new DataTestActivity(running, now, null),
        new DataTestActivity(running, null, 1000), new DataTestActivity(running, now + 1, 5000),
        new DataTestActivity(running, now, 1234), new DataTestActivity(running, now - 86400, 2000),
        new DataTestActivity(running, now, 66), new DataTestActivity(running, now - 6 * 86400, 3000)];
    source.readRuns(today, now);
    Test.assertEqual(source.runs[6], 1300);
    Test.assertEqual(source.runs[5], 2000);
    Test.assertEqual(source.runs[0], 3000);
    Test.assertEqual(source.runs[1], 0);
    source.readRuns(today, now);
    Test.assertEqual(source.runs[6], 1300);
    source.activityRows = null;
    source.readRuns(today, now);
    Test.assert(source.runs == null);
    Test.assert(source.supportsHistory);
    source.activityRows = [];
    source.readRuns(today, now);
    Test.assert(source.runs == null);
    return true;
}

(:test)
function dataInvalidHeartRateZones(logger) {
    var source = new DataTestSource();
    source.thresholds = [90, 110, 130, 150, 170, 190];
    source.readProfile(2027);
    Test.assertEqual(source.zones[5], 190);
    source.thresholds = [90, 110, 109, 150, 170, 190];
    source.readProfile(2027);
    Test.assert(source.zones == null);
    source.thresholds = [90, 110, null, 150, 170, 190];
    source.readProfile(2027);
    Test.assert(source.zones == null);
    source.thresholds = [0, 110, 130, 150, 170, 190];
    source.readProfile(2027);
    Test.assert(source.zones == null);
    source.thresholds = [90, 110, 130, 150, 170];
    source.readProfile(2027);
    Test.assert(source.zones == null);
    return true;
}

(:test)
function dataRollbackAfterPartialFailure(logger) {
    var source = new DataTestSource();
    var start = 1800000000;
    source.refresh(new Toybox.Time.Moment(start));
    source.failHistory = true;
    var propagated = false;
    try { source.refresh(new Toybox.Time.Moment(start + 900)); }
    catch (error instanceof Toybox.Lang.Exception) { propagated = true; }
    Test.assert(propagated);
    Test.assertEqual(source.profileReads, 2);
    source.failHistory = false;
    source.refresh(new Toybox.Time.Moment(start + 600));
    Test.assertEqual(source.profileReads, 3);
    Test.assertEqual(source.historyReads, 3);
    return true;
}

(:test)
function dataDeviceCapabilityIntrospection(logger) {
    var source = new FaceData();
    if ((Toybox has :ActivityMonitor) && (Toybox.ActivityMonitor has :getInfo)) {
        var info = Toybox.ActivityMonitor.getInfo();
        if (info != null) {
            Test.assertEqual(source.supportsSteps, info has :steps);
            Test.assertEqual(source.supportsRecovery, info has :timeToRecovery);
        }
    }
    if ((Toybox has :UserProfile) && (Toybox.UserProfile has :getProfile)) {
        var profile = Toybox.UserProfile.getProfile();
        if (profile != null) {
            Test.assertEqual(source.supportsVo2, profile has :vo2maxRunning);
        }
    }
    return true;
}
