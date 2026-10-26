import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ZsvirtTimeView extends WatchUi.WatchFace {
    // Bitmap resources use different runtime types before and after API 4.0.
    private var _logo;
    private var _centerX as Number = 0;
    private var _height as Number = 0;
    private var _logoX as Number = 0;
    private var _logoY as Number = 0;
    private var _timeY as Number = 0;
    private var _periodY as Number = 0;
    private var _metricsY as Number = 0;
    private var _batteryX as Number = 0;
    private var _batteryTextX as Number = 0;
    private var _stepsX as Number = 0;
    private var _stepsTextX as Number = 0;
    private var _unit as Number = 1;
    private var _timeFont = Graphics.FONT_NUMBER_HOT;
    private var _aodFont = Graphics.FONT_NUMBER_MILD;
    private var _aodPeriodOffset as Number = 0;
    private var _sleeping as Boolean = false;
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
        _logo = WatchUi.loadResource(Rez.Drawables.ZsvirtLogo);
        var width = dc.getWidth();
        _height = dc.getHeight();
        _centerX = width / 2;
        _unit = width >= 360 ? 2 : 1;
        _logoX = (width - _logo.getWidth()) / 2;
        var smallHeight = dc.getFontHeight(Graphics.FONT_XTINY);
        var gap = 4 * _unit;
        var fixedHeight = _logo.getHeight() + 2 * smallHeight + 3 * gap;
        var availableTimeHeight = _height * 4 / 5 - fixedHeight;
        _timeFont = Graphics.FONT_NUMBER_HOT;
        if (dc.getTextWidthInPixels("88:88", _timeFont) > width * 9 / 10 ||
                dc.getFontHeight(_timeFont) > availableTimeHeight) {
            _timeFont = Graphics.FONT_NUMBER_MEDIUM;
        }
        if (dc.getTextWidthInPixels("88:88", _timeFont) > width * 9 / 10 ||
                dc.getFontHeight(_timeFont) > availableTimeHeight) {
            _timeFont = Graphics.FONT_NUMBER_MILD;
        }
        var timeHeight = dc.getFontHeight(_timeFont);
        _logoY = (_height - fixedHeight - timeHeight) / 2;
        _timeY = _logoY + _logo.getHeight() + gap + timeHeight / 2;
        _periodY = _timeY + (timeHeight + smallHeight) / 2 + gap;
        _metricsY = _periodY + smallHeight + gap;
        var batteryWidth = dc.getTextWidthInPixels("100%", Graphics.FONT_XTINY);
        var stepsWidth = dc.getTextWidthInPixels("888888", Graphics.FONT_XTINY);
        var rowWidth = batteryWidth + stepsWidth + 68 * _unit;
        _batteryX = (width - rowWidth) / 2;
        _batteryTextX = _batteryX + 26 * _unit;
        _stepsX = _batteryTextX + batteryWidth + 16 * _unit;
        _stepsTextX = _stepsX + 26 * _unit;
        if (DeviceProfile.AMOLED) {
            // Bound complete text rectangles below 10% of the circular display.
            _aodFont = Graphics.FONT_NUMBER_MILD;
            var periodWidth = dc.getTextWidthInPixels("AM", Graphics.FONT_XTINY);
            var pmWidth = dc.getTextWidthInPixels("PM", Graphics.FONT_XTINY);
            if (pmWidth > periodWidth) {
                periodWidth = pmWidth;
            }
            var periodArea = periodWidth * smallHeight;
            if (dc.getTextWidthInPixels("88:88", _aodFont) * dc.getFontHeight(_aodFont) +
                    periodArea > width * _height * 7 / 100) {
                _aodFont = Graphics.FONT_MEDIUM;
            }
            _aodPeriodOffset = (dc.getFontHeight(_aodFont) + smallHeight) / 2 + gap;
        }
    }

    function onEnterSleep() as Void {
        _sleeping = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        _sleeping = false;
        WatchUi.requestUpdate();
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
        if (DeviceProfile.AMOLED && _sleeping) {
            // Consecutive minutes occupy disjoint halves, so no pixel stays lit.
            var y = (_minute % 2 == 0) ? _height / 4 : _height * 3 / 4;
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, y, _aodFont, _time,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            if (!_is24Hour) {
                dc.drawText(_centerX, y + _aodPeriodOffset, Graphics.FONT_XTINY, _period,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
            return;
        }

        var battery = System.getSystemStats().battery.toNumber();
        if (battery != _battery) {
            _battery = battery;
            _batteryFill = battery * 12 * _unit / 100;
            _batteryText = battery.toString() + "%";
        }
        var steps = ActivityMonitor.getInfo().steps;
        if (steps != _steps) {
            _steps = steps;
            _stepsText = steps == null ? "--" : steps.toString();
        }

        var logo = _logo;
        if (logo != null) {
            dc.drawBitmap(_logoX, _logoY, logo);
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _timeY, _timeFont, _time,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        if (!_is24Hour) {
            dc.drawText(_centerX, _periodY, Graphics.FONT_XTINY, _period,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        var u = _unit;
        dc.drawRectangle(_batteryX, _metricsY - 5 * u, 18 * u, 10 * u);
        dc.fillRectangle(_batteryX + 18 * u, _metricsY - 2 * u, 2 * u, 4 * u);
        if (_batteryFill > 0) {
            dc.fillRectangle(_batteryX + 3 * u, _metricsY - 2 * u, _batteryFill, 4 * u);
        }
        dc.drawText(_batteryTextX, _metricsY, Graphics.FONT_XTINY, _batteryText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.fillEllipse(_stepsX, _metricsY - u, 3 * u, 5 * u);
        dc.fillCircle(_stepsX, _metricsY + 7 * u, 2 * u);
        dc.fillEllipse(_stepsX + 8 * u, _metricsY - 8 * u, 3 * u, 5 * u);
        dc.fillCircle(_stepsX + 8 * u, _metricsY, 2 * u);
        dc.drawText(_stepsTextX, _metricsY, Graphics.FONT_XTINY, _stepsText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
