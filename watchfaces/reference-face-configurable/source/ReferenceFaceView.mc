import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class ReferenceFaceView extends WatchUi.WatchFace {
    const WHITE = 0xffffff;
    const DIM = 0xaaaaaa;
    const TRACK = 0x555555;
    const ORANGE = 0xffaa00;
    const DIGIT_TEXT = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
    const ZONE_COLORS = [0xaaaaaa, 0x00aaff, 0x00ff00, 0xffaa00, 0xff0000];
    const DAILY_ORDER = [1, 2, 3, 9, 5, 4, 6, 7, 8];
    const TRAINING_ORDER = [5, 4, 1, 6, 2, 3, 9, 7, 8];
    const LABELS = ["", "心率", "身体电量", "温度 °C", "恢复 h", "周跑量 km", "摄氧量", "日出", "降雨 %", "步数"];
    const SHORT_LABELS = ["", "心率", "身体电量", "温度°C", "恢复h", "跑量km", "摄氧量", "日出", "降雨%", "步数"];

    var data;
    var smallFont;
    var numberFont;
    var detailFont;
    var fitFont = null;
    var timeFont = null;
    var ambientFont = null;
    var denseTime = false;
    var fontMetricsDirty = true;
    var timeText = "00:00";
    var timeHeight = 0;
    var ambientHeight = 0;
    var detailHeight = 0;
    var secondAdvance = 0;
    var sx = 1.0;
    var sy = 1.0;
    var compact = false;
    var small = false;
    var sleeping = false;
    var use24Hour = true;
    var dayKey = null;
    var dateText = "";
    var calendarText = "";
    var readingMinute = null;
    var batteryText = "--";
    var zoneText = "心率区 --";
    var selected = [0, 0, 0, 0, 0, 0];
    var values = ["", "", "", "", "", ""];
    var details = ["", "", "", "", "", ""];
    var headerText = "";
    var valueFonts = [null, null, null, null, null, null];
    var count = 0;
    var runHeights = [0, 0, 0, 0, 0, 0, 0];
    var activeZone = -1;
    var labelHeight = 15.0;
    var valueHeight = 17.0;
    var columns = 2;
    var cellWidth = 102;
    var historyVisible = false;
    var horizontalCells = false;
    var valueOffsets = [0, 0, 0, 0, 0, 0];
    var timeY = 0;
    var calendarY = 0;
    var gridStart = 0;
    var rowHeight = 0;
    var historyTitleY = 0;
    var historyBottom = 0;
    var historyAxisY = 0;
    var zoneLabelY = 0;
    var zoneBarY = 0;

    function initialize() {
        WatchFace.initialize();
        data = new FaceData();
    }

    function onLayout(dc) {
        compact = dc.getHeight() < 200;
        small = dc.getWidth() <= 240 || compact;
        sx = dc.getWidth() / 280.0;
        sy = dc.getHeight() / (compact ? 200.0 : 280.0);
        smallFont = WatchUi.loadResource(Rez.Fonts.Label);
        detailFont = WatchUi.loadResource(Rez.Fonts.Detail);
        numberFont = WatchUi.loadResource(Rez.Fonts.Value);
        if (DeviceProfile.AMOLED) { ambientFont = WatchUi.loadResource(Rez.Fonts.TimeAmbient); }
        use24Hour = System.getDeviceSettings().is24Hour;
        reloadSettings();
    }

    function reloadSettings() {
        FaceSettings.load();
        var dense = FaceSettings.layout == FaceSettings.TRAINING && FaceSettings.showHistory && data.supportsHistory;
        if (timeFont == null || denseTime != dense) {
            timeFont = WatchUi.loadResource(dense ? Rez.Fonts.TimeDense : Rez.Fonts.Time);
            denseTime = dense;
        }
        fontMetricsDirty = true;
        readingMinute = null;
        dayKey = null;
    }

    function onEnterSleep() { sleeping = true; }
    function onExitSleep() { sleeping = false; }

    function onUpdate(dc) {
        var now = Time.now();
        var clock = System.getClockTime();
        var minute = (now.value() / 60).toNumber();
        if (fontMetricsDirty) {
            labelHeight = dc.getFontHeight(smallFont) / sy;
            detailHeight = dc.getFontHeight(detailFont) / sy;
            valueHeight = dc.getFontHeight(numberFont) / sy;
            timeHeight = dc.getFontHeight(timeFont) / sy;
            secondAdvance = dc.getTextWidthInPixels("0", smallFont) / sx;
            if (ambientFont != null) { ambientHeight = dc.getFontHeight(ambientFont) / sy; }
            fontMetricsDirty = false;
        }
        // Date strings, settings, metric strings and slot arrays are never built per second.
        if (readingMinute != minute || dayKey == null) {
            var hour = clock.hour;
            if (!use24Hour) { hour %= 12; if (hour == 0) { hour = 12; } }
            timeText = hour.format("%02d") + ":" + clock.min.format("%02d");
            var today = Gregorian.info(now, Time.FORMAT_SHORT);
            var key = FaceCalendar.dayNumber(today);
            if (dayKey != key) {
                dayKey = key;
                dateText = today.month.format("%02d") + "-" + today.day.format("%02d");
                calendarText = FaceCalendar.weekday(today.day_of_week);
                if (FaceSettings.showLunar) {
                    var lunar = FaceCalendar.lunar(today);
                    calendarText = (lunar == null ? "农历--" : lunar) + "  " + calendarText;
                }
            }
        }
        dc.setColor(WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        if (DeviceProfile.AMOLED && sleeping) {
            drawAmbient(dc, clock.min);
            return;
        }
        data.historyEnabled = FaceSettings.layout == FaceSettings.TRAINING && FaceSettings.showHistory;
        if (readingMinute != minute) {
            data.refresh(now);
            batteryText = metric(data.battery, "%");
            headerText = dateText + "  " + batteryText;
            resolveSlots();
            cacheMetrics(dc);
            zoneText = data.zones == null ? "未设区间" : (data.hr == null ? "心率区 --" : "心率区");
            readingMinute = minute;
        }
        drawFace(dc, clock);
    }

    function slotLimit() {
        if (FaceSettings.layout == FaceSettings.MINIMAL) { return 2; }
        return FaceSettings.layout == FaceSettings.TRAINING && !small ? 6 : 4;
    }

    function resolveSlots() {
        var limit = slotLimit();
        var order = FaceSettings.layout == FaceSettings.TRAINING ? TRAINING_ORDER : DAILY_ORDER;
        count = 0;
        for (var i = 0; i < limit; i += 1) {
            var id = FaceSettings.slots[i];
            if (id == FaceSettings.AUTO) {
                id = FaceSettings.NONE;
                for (var j = 0; j < order.size(); j += 1) {
                    var candidate = order[j];
                    var used = false;
                    // Explicit choices reserve their metric even when they appear later.
                    for (var k = 0; k < limit; k += 1) {
                        if (FaceSettings.slots[k] == candidate) { used = true; }
                    }
                    for (var k = 0; k < count; k += 1) {
                        if (selected[k] == candidate) { used = true; }
                    }
                    if (!used && data.supportsMetric(candidate)) { id = candidate; break; }
                }
            }
            if (id != FaceSettings.NONE) { selected[count] = id; count += 1; }
        }
    }

    function metric(value, unit) {
        return value == null ? "--" : value.toFloat().format("%.0f") + unit;
    }

    function goalText(value) {
        if (value == 0) { return "未设目标"; }
        var formatted = value.format("%.2f");
        var end = formatted.length();
        while (formatted.substring(end - 1, end).equals("0")) { end -= 1; }
        if (formatted.substring(end - 1, end).equals(".")) { end -= 1; }
        return "目标" + formatted.substring(0, end) + "km";
    }

    function cacheMetrics(dc) {
        historyVisible = data.historyEnabled && data.supportsHistory;
        columns = FaceSettings.layout == FaceSettings.TRAINING && !small && count > 4 ? 3 : 2;
        horizontalCells = small;
        cellWidth = columns == 3 ? 72 : (compact ? 132 : (horizontalCells ? 98 : 110));
        for (var i = 0; i < count; i += 1) {
            var id = selected[i];
            var value = "--";
            var detail = "";
            if (!data.supportsMetric(id)) {
                value = "不支持";
            } else if (id == FaceSettings.HEART_RATE) {
                value = metric(data.hr, "");
                detail = data.hr == null ? "无数据" : "最近" + (data.hrAgeSeconds / 60).toNumber().format("%d") + "m";
            } else if (id == FaceSettings.BODY_BATTERY) {
                value = metric(data.body, "");
            } else if (id == FaceSettings.WEATHER) {
                value = metric(data.temperature, "");
                detail = data.weatherStale ? "天气过期" : "体感 " + metric(data.feels, "°C");
            } else if (id == FaceSettings.RECOVERY) {
                value = metric(data.recovery, "");
            } else if (id == FaceSettings.WEEKLY_RUN) {
                value = data.weeklyMeters == null ? "--" : (data.weeklyMeters / 1000.0).format("%.1f");
                detail = goalText(FaceSettings.weeklyGoalKm);
                if (FaceSettings.weeklyGoalKm > 0) { detail = detail.substring(0, detail.length() - 2); }
            } else if (id == FaceSettings.VO2) {
                value = metric(data.vo2, "");
                detail = data.grade == null ? "" : data.grade;
            } else if (id == FaceSettings.SUNRISE) {
                if (data.sunrise != null) {
                    var minutes = (data.sunrise / 60).toNumber();
                    value = (minutes / 60).toNumber().format("%02d") + ":" + (minutes % 60).format("%02d");
                }
            } else if (id == FaceSettings.RAIN) {
                value = metric(data.rain, "");
                detail = data.weatherStale ? "天气过期" : "";
            } else if (id == FaceSettings.STEPS) {
                value = metric(data.steps, "");
            }
            if (horizontalCells && value.equals("不支持")) {
                detail = value;
                value = "";
            }
            values[i] = value;
            details[i] = detail;
            var available = px(cellWidth);
            if (horizontalCells) {
                available -= dc.getTextWidthInPixels(SHORT_LABELS[id], smallFont) + px(4);
            }
            valueFonts[i] = value == "不支持" ? detailFont : (dc.getTextWidthInPixels(value, numberFont) <= available ? numberFont : smallFont);
            if (dc.getTextWidthInPixels(value, valueFonts[i]) > available && value != "不支持") {
                if (fitFont == null) { fitFont = WatchUi.loadResource(Rez.Fonts.Fit); }
                valueFonts[i] = fitFont;
            }
            var lineHeight = horizontalCells ? max(labelHeight, valueHeight) : valueHeight;
            valueOffsets[i] = (lineHeight - dc.getFontHeight(valueFonts[i]) / sy) / 2;
        }
        if (data.historyEnabled && data.runs != null) {
            var maximum = 1.0;
            for (var i = 0; i < 7; i += 1) { maximum = max(maximum, data.runs[i]); }
            for (var i = 0; i < 7; i += 1) {
                runHeights[i] = (compact ? 10 : 12) * data.runs[i] / maximum;
            }
        }
        activeZone = -1;
        if (FaceSettings.showZones && data.hr != null && data.zones != null && data.zones.size() == 6 && data.hr >= data.zones[0]) {
            for (var z = 1; z < 6; z += 1) {
                if (data.hr <= data.zones[z]) { activeZone = z - 1; break; }
            }
            if (data.hr > data.zones[5]) { activeZone = 4; }
        }
        layoutFace();
    }

    function layoutFace() {
        var minimal = FaceSettings.layout == FaceSettings.MINIMAL;
        timeY = compact ? detailHeight + 2 : (historyVisible ? 28 : (minimal ? 52 : 46));
        calendarY = timeY + timeHeight + (compact ? 1 : 3);
        gridStart = calendarY + detailHeight + (compact ? 3 : (minimal ? 17 : 6));
        rowHeight = horizontalCells ? max(labelHeight, valueHeight) + detailHeight + 1 : labelHeight + valueHeight + detailHeight;
        var rows = ((count + columns - 1) / columns).toNumber();
        var end = gridStart + rows * rowHeight;
        historyTitleY = max(end + 1, compact ? 154 : 218);
        historyBottom = historyTitleY + detailHeight + (compact ? 10 : 12);
        historyAxisY = historyBottom + 1;
        zoneLabelY = historyVisible ? historyAxisY : (compact ? 180 : 248);
        zoneBarY = compact ? 197 : max(269, zoneLabelY + detailHeight + 1);
    }

    function drawFace(dc, clock) {
        detail(dc, 140, compact ? 0 : 8, headerText, DIM);
        drawTime(dc, timeY, timeFont, WHITE);
        detail(dc, FaceSettings.showSeconds ? 128 : 140, calendarY, calendarText, DIM);
        if (FaceSettings.showSeconds && !sleeping) {
            var secondY = calendarY + (detailHeight - labelHeight) / 2;
            text(dc, 239, secondY, DIGIT_TEXT[(clock.sec / 10).toNumber()], smallFont, DIM, Graphics.TEXT_JUSTIFY_LEFT);
            text(dc, 239 + secondAdvance, secondY, DIGIT_TEXT[clock.sec % 10], smallFont, DIM, Graphics.TEXT_JUSTIFY_LEFT);
        }
        rect(dc, 74, gridStart - 3, 132, 1, FaceSettings.accent);
        for (var i = 0; i < count; i += 1) {
            var row = (i / columns).toNumber();
            var inRow = count - row * columns;
            if (inRow > columns) { inRow = columns; }
            var spacing = compact ? 140 : (columns == 3 ? 76 : 112);
            var x = 140 + (i % columns - (inRow - 1) / 2.0) * spacing;
            var y = gridStart + row * rowHeight;
            var detailY;
            if (horizontalCells) {
                var lineHeight = max(labelHeight, valueHeight);
                if (values[i].equals("")) {
                    label(dc, x, y + (lineHeight - labelHeight) / 2, SHORT_LABELS[selected[i]], DIM);
                } else {
                    text(dc, x - cellWidth / 2, y + (lineHeight - labelHeight) / 2, SHORT_LABELS[selected[i]], smallFont, DIM, Graphics.TEXT_JUSTIFY_LEFT);
                    text(dc, x + cellWidth / 2, y + valueOffsets[i], values[i], valueFonts[i], WHITE, Graphics.TEXT_JUSTIFY_RIGHT);
                }
                detailY = y + lineHeight;
            } else {
                label(dc, x, y, LABELS[selected[i]], DIM);
                text(dc, x, y + labelHeight + valueOffsets[i], values[i], valueFonts[i], WHITE, Graphics.TEXT_JUSTIFY_CENTER);
                detailY = y + labelHeight + valueHeight;
            }
            detail(dc, x, detailY, details[i], details[i] == "天气过期" ? ORANGE : DIM);
        }
        if (historyVisible) { drawHistory(dc); }
        if (FaceSettings.showZones) { drawZones(dc); }
    }

    function drawHistory(dc) {
        detail(dc, 140, historyTitleY, data.runs == null ? "本地近7日 无数据" : "本地近7日", DIM);
        for (var j = 0; j < 7; j += 1) {
            rect(dc, 70 + j * 21, historyBottom, 14, 1, TRACK);
            if (data.runs != null && runHeights[j] > 0) {
                rect(dc, 70 + j * 21, historyBottom - runHeights[j], 14, runHeights[j], FaceSettings.accent);
            }
        }
        detail(dc, compact ? 82 : 94, historyAxisY, "-6日", DIM);
        detail(dc, compact ? 198 : 186, historyAxisY, "今天", DIM);
    }

    function drawZones(dc) {
        detail(dc, 140, zoneLabelY, zoneText, DIM);
        for (var i = 0; i < 5; i += 1) {
            rect(dc, 105 + i * 14, zoneBarY, 12, 3, data.zones == null ? TRACK : ZONE_COLORS[i]);
            if (i == activeZone) { rect(dc, 105 + i * 14, zoneBarY - 2, 12, 1, WHITE); }
        }
    }

    function drawAmbient(dc, minute) {
        var y = (minute % 2 == 0) ? 65 : 181;
        drawTime(dc, y, ambientFont, DIM);
        detail(dc, 140, y + ambientHeight + 5, dateText, DIM);
    }

    function px(x) { return (x * sx).toNumber(); }
    function py(y) { return (y * sy).toNumber(); }
    function max(a, b) { return a > b ? a : b; }

    function rect(dc, x, y, w, h, color) {
        if (w <= 0 || h <= 0) { return; }
        dc.setColor(color, Graphics.COLOR_BLACK);
        dc.fillRectangle(px(x), py(y), max(1, px(w)), max(1, py(h)));
    }

    function text(dc, x, y, value, font, color, align) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(px(x), py(y), font, value, align);
    }

    function label(dc, x, y, value, color) {
        text(dc, x, y, value, smallFont, color, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function detail(dc, x, y, value, color) {
        text(dc, x, y, value, detailFont, color, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawTime(dc, y, font, color) {
        text(dc, 140, y, timeText, font, color, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
