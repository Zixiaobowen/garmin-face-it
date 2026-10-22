import Toybox.Application;
import Toybox.Lang;

class FaceSettingsError extends Lang.Exception {
    private var message;

    function initialize(key) {
        Exception.initialize();
        message = "Invalid setting: " + key;
    }

    function getErrorMessage() { return message; }
}

module FaceSettings {
    const DAILY = 0;
    const TRAINING = 1;
    const MINIMAL = 2;
    const AUTO = -1;
    const NONE = 0;
    const HEART_RATE = 1;
    const BODY_BATTERY = 2;
    const WEATHER = 3;
    const RECOVERY = 4;
    const WEEKLY_RUN = 5;
    const VO2 = 6;
    const SUNRISE = 7;
    const RAIN = 8;
    const STEPS = 9;

    var layout = DAILY;
    var accent = 0xFF3333;
    var slots = [-1, -1, -1, -1, -1, -1];
    var showSeconds = true;
    var showLunar = true;
    var showHistory = true;
    var showZones = false;
    var weeklyGoalKm = 0.0;

    function validate(key, value) {
        if (!(key instanceof Lang.String)) { return false; }
        if (key.equals("LayoutMode")) {
            return value instanceof Lang.Number && value >= DAILY && value <= MINIMAL;
        }
        if (key.equals("AccentTheme")) {
            return value instanceof Lang.Number && value >= 0 && value <= 4;
        }
        for (var i = 1; i <= 6; i += 1) {
            if (key.equals("Metric" + i)) {
                return value instanceof Lang.Number && value >= AUTO && value <= STEPS;
            }
        }
        if (key.equals("ShowSeconds") || key.equals("ShowLunar") ||
            key.equals("ShowHistory") || key.equals("ShowZones")) {
            return value instanceof Lang.Boolean;
        }
        if (key.equals("WeeklyGoalKm")) {
            return (value instanceof Lang.Number || value instanceof Lang.Float) &&
                value >= 0 && value <= 1000;
        }
        return false;
    }

    function read(key) {
        var value;
        if (Application has :Properties) {
            value = Application.Properties.getValue(key);
        } else {
            // API 1.4 hardware exposes application settings through AppBase.
            value = Application.getApp().getProperty(key);
        }
        if (!validate(key, value)) {
            throw new FaceSettingsError(key);
        }
        return value;
    }

    function load() {
        layout = read("LayoutMode");
        var theme = read("AccentTheme");
        switch (theme) {
            case 0: accent = 0xFF3333; break;
            case 1: accent = 0x3399FF; break;
            case 2: accent = 0x33CC66; break;
            case 3: accent = 0xFF9900; break;
            case 4: accent = 0xFFFFFF; break;
        }
        for (var i = 0; i < 6; i += 1) {
            slots[i] = read("Metric" + (i + 1));
        }
        showSeconds = read("ShowSeconds");
        showLunar = read("ShowLunar");
        showHistory = read("ShowHistory");
        showZones = read("ShowZones");
        weeklyGoalKm = read("WeeklyGoalKm");
    }

    function save(key, value) {
        if (!validate(key, value)) {
            throw new FaceSettingsError(key);
        }
        if (key.equals("WeeklyGoalKm")) { value = value.toFloat(); }
        if (Application has :Properties) {
            Application.Properties.setValue(key, value);
        } else {
            // API 1.4 hardware exposes application settings through AppBase.
            Application.getApp().setProperty(key, value);
        }
        Application.getApp().onSettingsChanged();
    }
}
