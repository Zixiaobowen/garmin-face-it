import Toybox.Application;
import Toybox.WatchUi;

class ReferenceFaceApp extends Application.AppBase {
    var face;

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        face = new ReferenceFaceView();
        return [face];
    }

    (:onDeviceSettings)
    function getSettingsView() {
        FaceSettings.load();
        return [new FaceSettingsMenu(), new FaceSettingsMenuDelegate()];
    }

    (:propertyValidation)
    function onValidateProperty(key, value) {
        return FaceSettings.validate(key, value);
    }

    function onSettingsChanged() {
        if (face != null) {
            face.reloadSettings();
            WatchUi.requestUpdate();
        } else {
            FaceSettings.load();
        }
    }
}
