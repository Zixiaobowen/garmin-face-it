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

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var logo = _logo;
        if (logo != null) {
            dc.drawBitmap(_logoX, 68, logo);
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, 166, Graphics.FONT_NUMBER_HOT, _time,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        if (!_is24Hour) {
            dc.drawText(_centerX, 218, Graphics.FONT_XTINY, _period,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }
}
