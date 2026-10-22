import Toybox.Graphics;
import Toybox.WatchUi;

(:onDeviceSettings)
module FaceSettingsMenuLabels {
    var menuFont;

    function font() {
        if (menuFont == null) { menuFont = WatchUi.loadResource(Rez.Fonts.Menu); }
        return menuFont;
    }

    function menuOptions(title) {
        return {:title=>new WatchUi.Text({:text=>title, :font=>font(),
            :color=>Graphics.COLOR_WHITE, :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER}), :theme=>null};
    }

    function text(id) { return WatchUi.loadResource(id); }

    function choices(key) {
        if (key.equals("LayoutMode")) {
            return [Rez.Strings.Daily, Rez.Strings.Training, Rez.Strings.Minimal];
        }
        if (key.equals("AccentTheme")) {
            return [Rez.Strings.Red, Rez.Strings.Blue, Rez.Strings.Green,
                Rez.Strings.Orange, Rez.Strings.White];
        }
        return [Rez.Strings.Auto, Rez.Strings.Off, Rez.Strings.HeartRate,
            Rez.Strings.BodyBattery, Rez.Strings.Weather, Rez.Strings.Recovery,
            Rez.Strings.WeeklyRun, Rez.Strings.Vo2, Rez.Strings.Sunrise,
            Rez.Strings.Rain, Rez.Strings.Steps];
    }

    function offset(key) {
        return (key.equals("LayoutMode") || key.equals("AccentTheme")) ? 0 : -1;
    }

    function valueLabel(key) {
        var value = FaceSettings.read(key);
        if (key.equals("WeeklyGoalKm")) { return value.format("%.2f") + " km"; }
        if (key.equals("ShowSeconds") || key.equals("ShowLunar") ||
            key.equals("ShowHistory") || key.equals("ShowZones")) {
            return text(value ? Rez.Strings.On : Rez.Strings.Off);
        }
        return text(choices(key)[value - offset(key)]);
    }
}

(:onDeviceSettings)
class FaceMenuItem extends WatchUi.CustomMenuItem {
    var label;
    var subLabel;

    function initialize(title, subtitle, identifier) {
        CustomMenuItem.initialize(identifier, {});
        label = title;
        subLabel = subtitle;
    }

    function getLabel() { return label; }
    function getSubLabel() { return subLabel; }
    function setSubLabel(value) { subLabel = value; }

    function draw(dc) {
        var font = FaceSettingsMenuLabels.font();
        var height = dc.getFontHeight(font);
        var y = (dc.getHeight() - height * (subLabel == null ? 1 : 2)) / 2;
        dc.setColor(Graphics.COLOR_WHITE, isFocused() ? 0x555555 : Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, y, font, label, Graphics.TEXT_JUSTIFY_CENTER);
        if (subLabel != null) {
            dc.setColor(0xaaaaaa, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, y + height, font, subLabel, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}

(:onDeviceSettings)
class FaceSettingsMenu extends WatchUi.CustomMenu {
    function initialize() {
        CustomMenu.initialize(60, Graphics.COLOR_BLACK,
            FaceSettingsMenuLabels.menuOptions(FaceSettingsMenuLabels.text(Rez.Strings.SettingsTitle)));
        addSetting("LayoutMode", Rez.Strings.LayoutTitle);
        addSetting("AccentTheme", Rez.Strings.AccentTitle);
        addSetting("Metric1", Rez.Strings.Metric1Title);
        addSetting("Metric2", Rez.Strings.Metric2Title);
        addSetting("Metric3", Rez.Strings.Metric3Title);
        addSetting("Metric4", Rez.Strings.Metric4Title);
        addSetting("Metric5", Rez.Strings.Metric5Title);
        addSetting("Metric6", Rez.Strings.Metric6Title);
        addSetting("ShowSeconds", Rez.Strings.SecondsTitle);
        addSetting("ShowLunar", Rez.Strings.LunarTitle);
        addSetting("ShowHistory", Rez.Strings.HistoryTitle);
        addSetting("ShowZones", Rez.Strings.ZonesTitle);
        addSetting("WeeklyGoalKm", Rez.Strings.GoalTitle);
    }

    function addSetting(key, title) {
        addItem(new FaceMenuItem(FaceSettingsMenuLabels.text(title),
            FaceSettingsMenuLabels.valueLabel(key), key));
    }
}

(:onDeviceSettings)
class FaceSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() { Menu2InputDelegate.initialize(); }

    function onSelect(item) {
        var key = item.getId();
        if (key.equals("WeeklyGoalKm")) {
            var editor = new FaceGoalEditor(item);
            WatchUi.pushView(editor, new FaceGoalEditorDelegate(editor), WatchUi.SLIDE_IMMEDIATE);
        } else if (key.equals("ShowSeconds") || key.equals("ShowLunar") ||
            key.equals("ShowHistory") || key.equals("ShowZones")) {
            FaceSettings.save(key, !FaceSettings.read(key));
            item.setSubLabel(FaceSettingsMenuLabels.valueLabel(key));
            WatchUi.requestUpdate();
        } else {
            var menu = new WatchUi.CustomMenu(60, Graphics.COLOR_BLACK,
                FaceSettingsMenuLabels.menuOptions(item.getLabel()));
            var labels = FaceSettingsMenuLabels.choices(key);
            var offset = FaceSettingsMenuLabels.offset(key);
            var selected = FaceSettings.read(key);
            for (var i = 0; i < labels.size(); i += 1) {
                menu.addItem(new FaceMenuItem(FaceSettingsMenuLabels.text(labels[i]),
                    selected == i + offset ? FaceSettingsMenuLabels.text(Rez.Strings.On) : null,
                    i + offset));
            }
            menu.setFocus(selected - offset);
            WatchUi.pushView(menu, new FaceSettingChoiceDelegate(key, item), WatchUi.SLIDE_UP);
        }
    }

    function onBack() { WatchUi.popView(WatchUi.SLIDE_DOWN); }
}

(:onDeviceSettings)
class FaceSettingChoiceDelegate extends WatchUi.Menu2InputDelegate {
    var key;
    var parentItem;
    function initialize(propertyKey, item) {
        Menu2InputDelegate.initialize();
        key = propertyKey;
        parentItem = item;
    }
    function onSelect(item) {
        FaceSettings.save(key, item.getId());
        parentItem.setSubLabel(FaceSettingsMenuLabels.valueLabel(key));
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
    function onBack() { WatchUi.popView(WatchUi.SLIDE_DOWN); }
}

(:onDeviceSettings)
class FaceGoalEditor extends WatchUi.View {
    var parentItem;
    var whole;
    var fraction;
    var wholeText;
    var fractionText;
    var part = 0;
    var rangeError = false;
    var width;
    var height;
    var labels;
    var numberFont;

    function initialize(item) {
        View.initialize();
        parentItem = item;
        var hundredths = (FaceSettings.read("WeeklyGoalKm") * 100 + 0.5).toNumber();
        whole = (hundredths / 100).toNumber();
        fraction = hundredths % 100;
        cacheText();
        labels = [FaceSettingsMenuLabels.text(Rez.Strings.GoalEditorTitle),
            FaceSettingsMenuLabels.text(Rez.Strings.GoalRangeError),
            FaceSettingsMenuLabels.text(Rez.Strings.GoalWhole),
            FaceSettingsMenuLabels.text(Rez.Strings.GoalFraction),
            FaceSettingsMenuLabels.text(Rez.Strings.GoalNext),
            FaceSettingsMenuLabels.text(Rez.Strings.GoalSave),
            FaceSettingsMenuLabels.text(Rez.Strings.GoalBack),
            FaceSettingsMenuLabels.text(Rez.Strings.GoalCancel)];
    }

    function cacheText() {
        wholeText = whole.format("%d");
        fractionText = fraction.format("%02d");
    }

    function onLayout(dc) {
        width = dc.getWidth();
        height = dc.getHeight();
        numberFont = Graphics.FONT_NUMBER_MEDIUM;
        if (dc.getTextWidthInPixels("1000", numberFont) > width * 0.34 ||
            dc.getFontHeight(numberFont) > height * 0.20) {
            numberFont = WatchUi.loadResource(Rez.Fonts.Value);
        }
    }

    function adjust(delta) {
        if (part == 0) { whole = (whole + delta + 1001) % 1001; }
        else { fraction = (fraction + delta + 100) % 100; }
        rangeError = false;
        cacheText();
        WatchUi.requestUpdate();
    }

    function select() {
        if (part == 0) {
            part = 1;
            WatchUi.requestUpdate();
            return;
        }
        var goal = whole + fraction / 100.0;
        if (!FaceSettings.validate("WeeklyGoalKm", goal)) {
            rangeError = true;
            WatchUi.requestUpdate();
            return;
        }
        FaceSettings.save("WeeklyGoalKm", goal);
        parentItem.setSubLabel(FaceSettingsMenuLabels.valueLabel("WeeklyGoalKm"));
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function back() {
        if (part == 1) {
            part = 0;
            WatchUi.requestUpdate();
        } else { WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); }
    }

    function tap(x, y) {
        var row = y / height.toFloat();
        if (row >= 0.30 && row < 0.64) {
            part = x < width * 0.56 ? 0 : 1;
            WatchUi.requestUpdate();
        } else if (row >= 0.64 && row < 0.80) {
            adjust(x < width / 2 ? -1 : 1);
        } else if (row >= 0.80 && row < 0.92) { select(); }
        else if (row >= 0.92) { back(); }
    }

    function text(dc, x, y, value, font, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText((width * x).toNumber(), (height * y).toNumber(), font,
            value, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onUpdate(dc) {
        dc.clearClip();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        var font = FaceSettingsMenuLabels.font();
        text(dc, 0.5, 0.17, labels[rangeError ? 1 : 0], font,
            rangeError ? 0xffaa00 : Graphics.COLOR_WHITE);
        text(dc, 0.34, 0.31, labels[2], font, 0xaaaaaa);
        text(dc, 0.71, 0.31, labels[3], font, 0xaaaaaa);
        text(dc, 0.34, 0.40, wholeText, numberFont, Graphics.COLOR_WHITE);
        text(dc, 0.56, 0.40, ".", numberFont, Graphics.COLOR_WHITE);
        text(dc, 0.71, 0.40, fractionText, numberFont, Graphics.COLOR_WHITE);
        var center = part == 0 ? 0.34 : 0.71;
        var span = part == 0 ? 0.34 : 0.20;
        dc.setColor(FaceSettings.accent, Graphics.COLOR_BLACK);
        dc.fillRectangle((width * (center - span / 2)).toNumber(),
            (height * 0.61).toNumber(), (width * span).toNumber(), 2);
        text(dc, 0.32, 0.67, "-", Graphics.FONT_MEDIUM, Graphics.COLOR_WHITE);
        text(dc, 0.68, 0.67, "+", Graphics.FONT_MEDIUM, Graphics.COLOR_WHITE);
        text(dc, 0.5, 0.84, labels[part == 0 ? 4 : 5], font, Graphics.COLOR_WHITE);
        text(dc, 0.5, 0.93, labels[part == 0 ? 7 : 6], font, 0xaaaaaa);
    }
}

(:onDeviceSettings)
class FaceGoalEditorDelegate extends WatchUi.BehaviorDelegate {
    var editor;
    function initialize(view) {
        BehaviorDelegate.initialize();
        editor = view;
    }
    function onPreviousPage() { editor.adjust(1); return true; }
    function onNextPage() { editor.adjust(-1); return true; }
    // Let raw tap/key callbacks distinguish touch coordinates from Enter.
    function onSelect() { return false; }
    function onKey(event) {
        if (event.getKey() == WatchUi.KEY_ENTER) { editor.select(); return true; }
        return false;
    }
    function onBack() { editor.back(); return true; }
    function onTap(event) {
        var point = event.getCoordinates();
        editor.tap(point[0], point[1]);
        return true;
    }
}
