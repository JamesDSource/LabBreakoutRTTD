package unit;

import hcb.comp.Component;

class Unit extends Component {
    private var selectable: Selectable;
    private var roomExt: Room;
    private var unitController: UnitController;

    private override function init() {
        selectable = cast parentEntity.getComponentOfType(Selectable);
    }

    private override function addedToRoom() {
        roomExt = cast room;
        unitController = cast roomExt.playerController.getComponentOfType(UnitController);
    }
}