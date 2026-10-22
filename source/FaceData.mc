using Toybox.ActivityMonitor;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.UserProfile;

// Values retain the units of their documented Garmin source: metres, Celsius,
// recovery hours and local seconds since midnight. null is never a numeric zero.
class FaceData {
    var battery = null;
    var hr = null;
    var zones = null;
    var vo2 = null;
    var grade = null;
    var recovery = null;
    var body = null;
    var temperature = null;
    var feels = null;
    var rain = null;
    var sunrise = null;
    var weeklyMeters = null;
    var runs = null;
    var steps = null;
    var hrAgeSeconds = null;
    var bodyAgeSeconds = null;
    var weatherAgeSeconds = null;
    var historyEnabled = true;

    var supportsHr = false;
    var supportsVo2 = false;
    var supportsRecovery = false;
    var supportsBody = false;
    var supportsWeather = false;
    var supportsSunrise = false;
    var supportsWeekly = false;
    var supportsHistory = false;
    var supportsSteps = false;
    var weatherStale = false;

    private var _minute = null;
    private var _lastRefresh = null;
    private var _profileAt = null;
    private var _profileYear = null;
    private var _historyAt = null;
    private var _historyDay = null;
    private var _historyWasEnabled = false;
    private var _hrPeriod;
    private var _bodyOptions = null;
    private var _sunriseId = null;
    private var _weeklyId = null;
    private var _runBins = null;

    function initialize() {
        _hrPeriod = new Time.Duration(300);
        detectCapabilities();
    }

    // Class members describe device capability even before the first sample.
    function detectCapabilities() {
        supportsHr = (Toybox has :ActivityMonitor) &&
            (ActivityMonitor has :getHeartRateHistory);
        supportsSteps = (Toybox has :ActivityMonitor) &&
            (ActivityMonitor has :getInfo) && (ActivityMonitor.Info has :steps);
        supportsRecovery = (Toybox has :ActivityMonitor) &&
            (ActivityMonitor has :getInfo) && (ActivityMonitor.Info has :timeToRecovery);
        supportsVo2 = (Toybox has :UserProfile) &&
            (UserProfile has :getProfile) && (UserProfile.Profile has :vo2maxRunning);
        supportsBody = (Toybox has :SensorHistory) &&
            (Toybox.SensorHistory has :getBodyBatteryHistory);
        supportsWeather = (Toybox has :Weather) &&
            (Toybox.Weather has :getCurrentConditions);
        supportsHistory = (Toybox has :UserProfile) &&
            (UserProfile has :getUserActivityHistory);
        supportsSunrise = (Toybox has :Complications) &&
            (Toybox.Complications has :getComplication) &&
            (Toybox.Complications has :COMPLICATION_TYPE_SUNRISE);
        supportsWeekly = (Toybox has :Complications) &&
            (Toybox.Complications has :getComplication) &&
            (Toybox.Complications has :COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE);
    }

    function supportsMetric(id) {
        switch (id) {
            case FaceSettings.HEART_RATE: return supportsHr;
            case FaceSettings.BODY_BATTERY: return supportsBody;
            case FaceSettings.WEATHER: return supportsWeather;
            case FaceSettings.RECOVERY: return supportsRecovery;
            case FaceSettings.WEEKLY_RUN: return supportsWeekly;
            case FaceSettings.VO2: return supportsVo2;
            case FaceSettings.SUNRISE: return supportsSunrise;
            case FaceSettings.RAIN: return supportsWeather;
            case FaceSettings.STEPS: return supportsSteps;
        }
        return false;
    }

    function refresh(now) {
        var seconds = now.value();
        var minute = seconds / 60;
        var rolledBack = _lastRefresh != null && seconds < _lastRefresh;
        var today = Gregorian.info(now, Time.FORMAT_SHORT);
        var day = FaceCalendar.dayNumber(today);
        if (_minute == null || _minute != minute || rolledBack) {
            readBattery();
            readHeartRate(seconds);
            readActivityInfo();
            readBodyBattery(seconds);
            readWeather(seconds);
            readComplications();
        }
        if (_profileAt == null || rolledBack || seconds < _profileAt ||
            seconds - _profileAt >= 900 || _profileYear != today.year) {
            readProfile(today.year);
            _profileAt = seconds;
            _profileYear = today.year;
        }
        if (historyEnabled) {
            if (!_historyWasEnabled || _historyAt == null || rolledBack ||
                seconds < _historyAt || seconds - _historyAt >= 300 || _historyDay != day) {
                readRuns(day, seconds);
                _historyAt = seconds;
                _historyDay = day;
            }
        } else {
            runs = null;
        }
        // Failed reads propagate; never cache an incomplete minute or transition.
        _historyWasEnabled = historyEnabled;
        _minute = minute;
        _lastRefresh = seconds;
    }

    function readBattery() {
        var stats = System.getSystemStats();
        battery = null;
        if (stats != null && stats has :battery) {
            battery = stats.battery;
        }
    }

    private function isFresh(when, seconds, maximumAge) {
        if (when == null) {
            return false;
        }
        var age = seconds - when.value();
        return age >= 0 && age <= maximumAge;
    }

    function heartRateHistory() {
        return ActivityMonitor.getHeartRateHistory(_hrPeriod, true);
    }

    function readHeartRate(seconds) {
        hr = null;
        hrAgeSeconds = null;
        if (supportsHr) {
            var iterator = heartRateHistory();
            if (iterator != null) {
                var sample = iterator.next();
                while (sample != null) {
                    if ((sample has :when) && (sample has :heartRate) &&
                        isFresh(sample.when, seconds, 300) &&
                        sample.heartRate != null && sample.heartRate > 0 &&
                        sample.heartRate != 255) {
                        hr = sample.heartRate;
                        hrAgeSeconds = seconds - sample.when.value();
                        return;
                    }
                    sample = iterator.next();
                }
            }
        }
    }

    function readProfile(year) {
        vo2 = null;
        grade = null;
        zones = null;
        if (Toybox has :UserProfile) {
            if (UserProfile has :getProfile) {
                var profile = userProfile();
                if (profile != null) {
                    if (profile has :vo2maxRunning) {
                        vo2 = profile.vo2maxRunning;
                    }
                    if ((profile has :birthYear) && (profile has :gender)) {
                        grade = FaceCalendar.vo2Rating(vo2, profile.birthYear,
                            profile.gender, year);
                    }
                }
            }
            if ((UserProfile has :getHeartRateZones) &&
                (UserProfile has :HR_ZONE_SPORT_RUNNING)) {
                var thresholds = heartRateZones();
                if (thresholds != null && thresholds.size() == 6) {
                    var valid = true;
                    for (var i = 0; i < 6; i += 1) {
                        if (thresholds[i] == null || thresholds[i] <= 0) {
                            valid = false;
                        } else if (i > 0 && thresholds[i - 1] != null &&
                                   thresholds[i] < thresholds[i - 1]) {
                            valid = false;
                        }
                    }
                    if (valid) {
                        zones = thresholds;
                    }
                }
            }
        }
    }

    function userProfile() {
        return UserProfile.getProfile();
    }

    function heartRateZones() {
        return UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_RUNNING);
    }

    function activityInfo() {
        return ActivityMonitor.getInfo();
    }

    function readActivityInfo() {
        recovery = null;
        steps = null;
        if (supportsRecovery || supportsSteps) {
            var info = activityInfo();
            if (info != null) {
                if (supportsSteps && (info has :steps)) {
                    steps = info.steps;
                }
                if (supportsRecovery && (info has :timeToRecovery)) {
                    recovery = info.timeToRecovery;
                }
            }
        }
    }

    function bodyBatteryHistory() {
        if (_bodyOptions == null) {
            _bodyOptions = {
                :period => new Time.Duration(1800),
                :order => Toybox.SensorHistory.ORDER_NEWEST_FIRST
            };
        }
        return Toybox.SensorHistory.getBodyBatteryHistory(_bodyOptions);
    }

    function readBodyBattery(seconds) {
        body = null;
        bodyAgeSeconds = null;
        if (supportsBody) {
            var iterator = bodyBatteryHistory();
            if (iterator != null) {
                var sample = iterator.next();
                while (sample != null) {
                    if ((sample has :when) && (sample has :data) &&
                        isFresh(sample.when, seconds, 1800) &&
                        sample.data != null && sample.data >= 0 && sample.data <= 100) {
                        body = sample.data;
                        bodyAgeSeconds = seconds - sample.when.value();
                        return;
                    }
                    sample = iterator.next();
                }
            }
        }
    }

    function weatherConditions() {
        return Toybox.Weather.getCurrentConditions();
    }

    function readWeather(seconds) {
        temperature = null;
        feels = null;
        rain = null;
        weatherStale = false;
        weatherAgeSeconds = null;
        if (supportsWeather) {
            var conditions = weatherConditions();
            if (conditions == null || !(conditions has :observationTime) ||
                conditions.observationTime == null) {
                return;
            }
            var age = seconds - conditions.observationTime.value();
            weatherStale = age > 10800;
            if (age >= 0) {
                weatherAgeSeconds = age;
            }
            // Unknown/future observation times cannot establish fresh weather.
            if (weatherStale || age < 0) {
                return;
            }
            if (conditions has :temperature) {
                temperature = conditions.temperature;
            }
            if (conditions has :feelsLikeTemperature) {
                feels = conditions.feelsLikeTemperature;
            }
            if (conditions has :precipitationChance) {
                rain = conditions.precipitationChance;
            }
        }
    }

    function readComplications() {
        sunrise = null;
        weeklyMeters = null;
        supportsSunrise = false;
        supportsWeekly = false;
        if ((Toybox has :Complications) &&
            (Toybox.Complications has :getComplication)) {
            if (Toybox.Complications has :COMPLICATION_TYPE_SUNRISE) {
                supportsSunrise = true;
                if (_sunriseId == null) {
                    _sunriseId = new Toybox.Complications.Id(
                        Toybox.Complications.COMPLICATION_TYPE_SUNRISE);
                }
                try {
                    var sun = Toybox.Complications.getComplication(_sunriseId);
                    if (sun != null && sun has :value) {
                        sunrise = sun.value;
                    }
                } catch (error instanceof Toybox.Complications.ComplicationNotFoundException) {
                    supportsSunrise = false;
                }
            }
            if (Toybox.Complications has :COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE) {
                supportsWeekly = true;
                if (_weeklyId == null) {
                    _weeklyId = new Toybox.Complications.Id(
                        Toybox.Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE);
                }
                try {
                    var weekly = Toybox.Complications.getComplication(_weeklyId);
                    if (weekly != null && weekly has :value) {
                        weeklyMeters = weekly.value;
                    }
                } catch (error instanceof Toybox.Complications.ComplicationNotFoundException) {
                    supportsWeekly = false;
                }
            }
        }
    }

    function activityHistory() {
        return UserProfile.getUserActivityHistory();
    }

    function readRuns(today, seconds) {
        runs = null;
        if (supportsHistory) {
            if (_runBins != null) {
                for (var i = 0; i < 7; i += 1) {
                    _runBins[i] = 0;
                }
            }
            var iterator = activityHistory();
            if (iterator == null) {
                return;
            }
            var activity = iterator.next();
            while (activity != null) {
                // SPORT_RUNNING is a compile-time enum, never an Activity API call.
                if ((activity has :type) && (activity has :startTime) &&
                    (activity has :distance) &&
                    activity.type == Toybox.Activity.SPORT_RUNNING &&
                    activity.startTime != null && activity.distance != null &&
                    activity.distance >= 0 && activity.startTime.value() <= seconds) {
                    if (_runBins == null) {
                        _runBins = [0, 0, 0, 0, 0, 0, 0];
                    }
                    runs = _runBins;
                    var day = FaceCalendar.dayNumber(
                        Gregorian.info(activity.startTime, Time.FORMAT_SHORT));
                    var age = today - day;
                    if (age >= 0 && age < 7) {
                        _runBins[6 - age] += activity.distance;
                    }
                }
                // Ordering/retention are undocumented: do not stop at an old row.
                activity = iterator.next();
            }
        }
    }
}
