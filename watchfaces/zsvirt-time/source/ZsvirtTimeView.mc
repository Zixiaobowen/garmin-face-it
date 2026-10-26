import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ZsvirtTimeView extends WatchUi.WatchFace {
    private var _logo as Graphics.BitmapReference?;
    private var _centerX as Number = 140;
    private var _logoX as Number = 60;
    private var _hour as Number = -1;
    private var _minute as Number = -1;
    private var _is24Hour as Boolean = true;
    private var _time as String = "";
    private var _period as String = "";
    private var _battery as Number = -1;
    private var _batteryFill as Number = 0;
    private var _batteryText as String = "";
    private var _steps as Number?;
    private var _stepsText as String = "--";

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        _logo = WatchUi.loadResource(Rez.Drawables.ZsvirtLogo) as Graphics.BitmapReference;
        _centerX = dc.getWidth() / 2;
        _logoX = _centerX - 80;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var clock = System.getClockTime();
        var is24Hour = System.getDeviceSettings().is24Hour;
        if (clock.hour != _hour || clock.min != _minute || is24Hour != _is24Hour) {
            _hour = clock.hour;
            _minute = clock.min;
            _is24Hour = is24Hour;
            _time = FaceTime.format(_hour, _minute, _is24Hour);
            _period = FaceTime.period(_hour, _is24Hour);
        }

        var battery = System.getSystemStats().battery.toNumber();
        if (battery != _battery) {
            _battery = battery;
            _batteryFill = battery * 12 / 100;
            _batteryText = battery.toString() + "%";
        }
        var steps = ActivityMonitor.getInfo().steps;
        if (steps != _steps) {
            _steps = steps;
            _stepsText = steps == null ? "--" : steps.toString();
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var logo = _logo;
        if (logo != null) {
            dc.drawBitmap(_logoX, 60, logo);
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, 158, Graphics.FONT_NUMBER_HOT, _time,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        if (!_is24Hour) {
            dc.drawText(_centerX, 197, Graphics.FONT_XTINY, _period,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        dc.drawRectangle(60, 220, 18, 10);
        dc.fillRectangle(78, 223, 2, 4);
        if (_batteryFill > 0) {
            dc.fillRectangle(63, 223, _batteryFill, 4);
        }
        dc.drawText(86, 225, Graphics.FONT_XTINY, _batteryText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.fillEllipse(148, 224, 3, 5);
        dc.fillCircle(148, 232, 2);
        dc.fillEllipse(156, 217, 3, 5);
        dc.fillCircle(156, 225, 2);
        dc.drawText(168, 225, Graphics.FONT_XTINY, _stepsText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
