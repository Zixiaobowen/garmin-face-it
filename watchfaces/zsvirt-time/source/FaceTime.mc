import Toybox.Lang;

module FaceTime {
    function format(hour as Number, minute as Number, is24Hour as Boolean) as String {
        var displayHour = hour;
        if (!is24Hour) {
            displayHour = hour % 12;
            if (displayHour == 0) {
                displayHour = 12;
            }
        }
        return displayHour.format("%02d") + ":" + minute.format("%02d");
    }

    function period(hour as Number, is24Hour as Boolean) as String {
        if (is24Hour) {
            return "";
        }
        return hour < 12 ? "AM" : "PM";
    }
}
