package unit;

import hxd.Res;

class Engineer extends Unit {
    private override function init() {
        super.init();

        selectable.actions.push({
            name: "Build",
            icon: Res.TexturePack.get("BuildActionIcon"),
            callBack: buildCallback,
            active: true,
        });
        selectable.actions.push({
            name: "Repair",
            icon: Res.TexturePack.get("RepairActionIcon"),
            callBack: repairCallback,
            active: true
        });
        selectable.actions.push({
            name: "Remove",
            icon: Res.RemoveActionIcon.toTile(),
            callBack: removeCallback,
            active: true
        });
    }

    private function buildCallback() {

    }

    private function repairCallback() {

    }

    private function removeCallback() {
        unitController.point((a) -> trace(a.length));
    }
}