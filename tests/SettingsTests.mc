import Toybox.Application;
import Toybox.Lang;
import Toybox.Test;

(:test)
function settingsRejectInvalidInputs(logger) {
    Test.assert(!FaceSettings.validate("LayoutMode", -1));
    Test.assert(!FaceSettings.validate("LayoutMode", 3));
    Test.assert(!FaceSettings.validate("LayoutMode", 1.0));
    Test.assert(!FaceSettings.validate("AccentTheme", 5));
    Test.assert(!FaceSettings.validate("Metric1", -2));
    Test.assert(!FaceSettings.validate("Metric6", 10));
    Test.assert(!FaceSettings.validate("Metric0", 1));
    Test.assert(!FaceSettings.validate("Metric7", 1));
    Test.assert(!FaceSettings.validate("ShowSeconds", 1));
    Test.assert(!FaceSettings.validate("ShowHistory", "true"));
    Test.assert(!FaceSettings.validate("WeeklyGoalKm", -0.01));
    Test.assert(!FaceSettings.validate("WeeklyGoalKm", 1000.01));
    Test.assert(!FaceSettings.validate("WeeklyGoalKm", "35"));
    Test.assert(!FaceSettings.validate("WeeklyGoalKm", null));
    Test.assert(!FaceSettings.validate("UnknownSetting", true));
    Test.assert(!FaceSettings.validate(null, 1));
    return true;
}

(:test)
function settingsAcceptCompleteRanges(logger) {
    for (var layout = 0; layout <= 2; layout += 1) {
        Test.assert(FaceSettings.validate("LayoutMode", layout));
    }
    for (var theme = 0; theme <= 4; theme += 1) {
        Test.assert(FaceSettings.validate("AccentTheme", theme));
    }
    for (var slot = 1; slot <= 6; slot += 1) {
        for (var metric = -1; metric <= 9; metric += 1) {
            Test.assert(FaceSettings.validate("Metric" + slot, metric));
        }
    }
    var toggles = ["ShowSeconds", "ShowLunar", "ShowHistory", "ShowZones"];
    for (var i = 0; i < toggles.size(); i += 1) {
        Test.assert(FaceSettings.validate(toggles[i], true));
        Test.assert(FaceSettings.validate(toggles[i], false));
    }
    Test.assert(FaceSettings.validate("WeeklyGoalKm", 0));
    Test.assert(FaceSettings.validate("WeeklyGoalKm", 37.25));
    Test.assert(FaceSettings.validate("WeeklyGoalKm", 1000.0));
    return true;
}

(:test)
module SettingsTestProperties {
    function read(key) {
        if (Application has :Properties) {
            return Application.Properties.getValue(key);
        }
        return Application.getApp().getProperty(key);
    }

    function write(key, value) {
        if (Application has :Properties) {
            Application.Properties.setValue(key, value);
        } else {
            Application.getApp().setProperty(key, value);
        }
    }
}

(:test)
function settingsPersistAndNotify(logger) {
    var app = Application.getApp();
    var keys = ["LayoutMode", "AccentTheme", "Metric1", "Metric2", "Metric3", "Metric4",
        "Metric5", "Metric6", "ShowSeconds", "ShowLunar", "ShowHistory", "ShowZones", "WeeklyGoalKm"];
    var saved = [];
    for (var i = 0; i < keys.size(); i += 1) { saved.add(SettingsTestProperties.read(keys[i])); }
    var face = app.face;
    // Exercise the real notification path when settings launch without the watch-face view.
    app.face = null;
    try {
        FaceSettings.save("LayoutMode", 1);
        Test.assertEqual(SettingsTestProperties.read("LayoutMode"), 1);
        Test.assertEqual(FaceSettings.layout, 1);
        FaceSettings.save("AccentTheme", 4);
        Test.assertEqual(SettingsTestProperties.read("AccentTheme"), 4);
        Test.assertEqual(FaceSettings.accent, 0xFFFFFF);
        for (var slot = 1; slot <= 6; slot += 1) {
            FaceSettings.save("Metric" + slot, slot);
            Test.assertEqual(SettingsTestProperties.read("Metric" + slot), slot);
            Test.assertEqual(FaceSettings.slots[slot - 1], slot);
        }
        FaceSettings.save("ShowSeconds", false);
        FaceSettings.save("ShowLunar", false);
        FaceSettings.save("ShowHistory", false);
        FaceSettings.save("ShowZones", true);
        Test.assertEqual(FaceSettings.showSeconds, false);
        Test.assertEqual(FaceSettings.showLunar, false);
        Test.assertEqual(FaceSettings.showHistory, false);
        Test.assertEqual(FaceSettings.showZones, true);
        FaceSettings.save("WeeklyGoalKm", 37.25);
        Test.assertEqual(SettingsTestProperties.read("WeeklyGoalKm"), 37.25);
        Test.assertEqual(FaceSettings.weeklyGoalKm, 37.25);
        // Discard the cache and reload the persisted non-preset decimal value.
        FaceSettings.weeklyGoalKm = 0.0;
        FaceSettings.load();
        Test.assertEqual(FaceSettings.weeklyGoalKm, 37.25);
        var rejected = false;
        try { FaceSettings.save("WeeklyGoalKm", 1000.01); }
        catch (error instanceof FaceSettingsError) { rejected = true; }
        Test.assert(rejected);
        Test.assertEqual(SettingsTestProperties.read("WeeklyGoalKm"), 37.25);
        Test.assertEqual(FaceSettings.weeklyGoalKm, 37.25);
        FaceSettings.save("WeeklyGoalKm", 1000);
        Test.assertEqual(FaceSettings.weeklyGoalKm, 1000.0);
        FaceSettings.save("WeeklyGoalKm", 0);
        Test.assertEqual(FaceSettings.weeklyGoalKm, 0.0);
    } finally {
        for (var i = 0; i < keys.size(); i += 1) { SettingsTestProperties.write(keys[i], saved[i]); }
        app.face = face;
        app.onSettingsChanged();
    }
    return true;
}

(:test)
function settingsRejectCorruptPersistedValue(logger) {
    var saved = SettingsTestProperties.read("Metric6");
    var rejected = false;
    try {
        SettingsTestProperties.write("Metric6", 99);
        try { FaceSettings.load(); }
        catch (error instanceof FaceSettingsError) { rejected = true; }
        Test.assert(rejected);
    } finally {
        SettingsTestProperties.write("Metric6", saved);
        FaceSettings.load();
    }
    return true;
}
