import Toybox.Test;

(:test)
class DisplayCapabilityData {
    var supported;
    function initialize(ids) { supported = ids; }
    function supportsMetric(id) {
        for (var i = 0; i < supported.size(); i += 1) {
            if (supported[i] == id) { return true; }
        }
        return false;
    }
}

(:test)
function displaySlotLimits(logger) {
    var savedLayout = FaceSettings.layout;
    var view = new ReferenceFaceView();
    FaceSettings.layout = FaceSettings.DAILY;
    var daily = view.slotLimit();
    FaceSettings.layout = FaceSettings.TRAINING;
    var training = view.slotLimit();
    view.small = true;
    var trainingSmall = view.slotLimit();
    FaceSettings.layout = FaceSettings.MINIMAL;
    var minimal = view.slotLimit();
    FaceSettings.layout = savedLayout;
    Test.assertEqual(daily, 4);
    Test.assertEqual(training, 6);
    Test.assertEqual(trainingSmall, 4);
    Test.assertEqual(minimal, 2);
    return true;
}

(:test)
function displayAutomaticReservesExplicitAndClosesGaps(logger) {
    var savedLayout = FaceSettings.layout;
    var savedSlots = FaceSettings.slots;
    FaceSettings.layout = FaceSettings.DAILY;
    // Later explicit HR must reserve HR before the first automatic slot is resolved.
    FaceSettings.slots = [-1, 0, 1, -1, 5, 6];
    var view = new ReferenceFaceView();
    view.data = new DisplayCapabilityData([1, 3, 9]);
    view.resolveSlots();
    FaceSettings.layout = savedLayout;
    FaceSettings.slots = savedSlots;
    Test.assertEqual(view.count, 3);
    Test.assertEqual(view.selected[0], 3);
    Test.assertEqual(view.selected[1], 1);
    Test.assertEqual(view.selected[2], 9);
    return true;
}

(:test)
function displayUnsupportedExplicitSurvivesCapabilitySelection(logger) {
    var savedLayout = FaceSettings.layout;
    var savedSlots = FaceSettings.slots;
    FaceSettings.layout = FaceSettings.TRAINING;
    FaceSettings.slots = [4, -1, -1, 0, -1, -1];
    var view = new ReferenceFaceView();
    view.data = new DisplayCapabilityData([1, 9]);
    view.resolveSlots();
    FaceSettings.layout = savedLayout;
    FaceSettings.slots = savedSlots;
    Test.assertEqual(view.count, 3);
    Test.assertEqual(view.selected[0], 4);
    Test.assertEqual(view.selected[1], 1);
    Test.assertEqual(view.selected[2], 9);
    return true;
}
