package unit;

import hcb.comp.Component;

class Unit extends Component {
    private var selectable: Selectable;
    private var roomExt: Room;
    private var unitController: UnitController;
    private var movement: MoveableUnit;

    private override function init() {
        selectable = cast parentEntity.getComponentOfType(Selectable);
        movement = cast parentEntity.getComponentOfType(MoveableUnit);
    }

    private override function addedToRoom() {
        roomExt = cast room;
        unitController = cast roomExt.playerController.getComponentOfType(UnitController);
    }
}