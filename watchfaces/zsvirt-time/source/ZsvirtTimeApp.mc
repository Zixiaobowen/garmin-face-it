import Toybox.Application;
import Toybox.WatchUi;

class ZsvirtTimeApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return [new ZsvirtTimeView()];
    }
}
