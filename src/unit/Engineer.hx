package unit;

import hcb.comp.col.CollisionShape;
import VectorMath.distance;
import building.Building;
import ControlPanel.ActionButton;
import building.BuildingPrefabs;
import hcb.Entity;
import hxd.Res;

enum State {
    Idle;
    Build;
    Repair;
    Destroy;
}

class Engineer extends Unit {
    private var state: State = State.Idle;
    private var buildSpeed: Float = 0.01;

    public var buildEnt(default, set): Entity = null;
    private var buildBuilding: Building = null;

    public var repairEnt: Entity = null;
    private var repaurHp: Health = null;

    public var destroyEnt: Entity = null;

    private function set_buildEnt(buildEnt: Entity): Entity {
        var buildingComp: Building = cast buildEnt.getComponentOfType(Building);
        if(buildingComp != null) {
            this.buildEnt = buildEnt;
            buildBuilding = buildingComp;
            movement.setTarget(buildEnt.getPosition());
            state = State.Build;
        }
        return this.buildEnt;
    }

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

    private override function addedToRoom() {
        super.addedToRoom();
        unitController.moveToEventSubscribe(parentEntity, onMoveTo);
    }

    private override function update() {
        super.update();
        stateMachine();
    }

    private function stateMachine() {
        switch(state) {
            case State.Idle:
            case State.Build:
                if(!room.hasEntity(buildEnt)) {
                    state = State.Idle;
                    return;
                }

                var d = distance(parentEntity.getPosition(), buildEnt.getPosition());
                if(d < 16) {
                    buildBuilding.addProgress(buildSpeed);
                    if(buildBuilding.isDone())
                        state = State.Idle;
                }
            case State.Repair:
            case State.Destroy:
        }
    }

    private function buildCallback() {
        ControlPanel.instance.queryBuildings(
            (b: ActionButton) -> {
                var buildingAction: BuildingAction = cast b.action;
                var buildingEnt: Entity = new Entity(buildingAction.prefab(buildingAction.cost));
                room.addEntity(buildingEnt);
                unitController.setPlaceable(buildingEnt);
                ControlPanel.instance.metals -= buildingAction.cost;

                var placeable: Placeable = cast buildingEnt.getComponentOfType(Placeable);
                placeable.onPlaced = (pos) -> buildEnt = buildingEnt;
            }
        );
    }

    private function repairCallback() {

    }

    private function removeCallback() {
        unitController.point((a) -> trace(a.length));
    }

    private function onMoveTo(results: Array<CollisionShape>, pos: Vec2) {
        state = State.Idle;
        for(result in results) {
            if(result.parentEntity == null)
                continue;

            var buildingComp: Building = cast result.parentEntity.getComponentOfType(Building);
            if(buildingComp != null && !buildingComp.isDone()) {
                buildEnt = result.parentEntity;
                break;
            }
        }
    }
}