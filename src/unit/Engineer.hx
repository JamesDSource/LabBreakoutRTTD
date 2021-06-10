package unit;

import hcb.math.Vector;
import hcb.Origin.OriginPoint;
import hcb.comp.anim.Animation;
import haxe.extern.Rest;
import hcb.comp.col.CollisionShape;
import VectorMath.distance;
import building.Building;
import ControlPanel.ActionButton;
import building.BuildingPrefabs;
import hcb.Entity;
import hxd.Res;

enum EngineerState {
    Idle;
    Build;
    Repair;
    Destroy;
}

class Engineer extends Unit {
    public static var fucknuggets: Int = 5;

    private var state: EngineerState = EngineerState.Idle;
    private var buildSpeed: Float = 0.002;

    public var buildEnt(default, set): Entity = null;
    private var buildBuilding: Building = null;

    public var repairEnt: Entity = null;
    private var repaurHp: Health = null;

    public var destroyEnt: Entity = null;

    private var idleAnimation: Animation;
    private var runAnimation: Animation;
    private var interfaceAnimation: Animation;

    private final buildingStatus: String = "Building";
    private final idlingStatus: String = "Idling";
    private final destroyingStatus: String = "Removing";
    private final repairStatus: String = "Repairing";

    private function set_buildEnt(buildEnt: Entity): Entity {
        var buildingComp: Building = cast buildEnt.getComponentOfType(Building);
        if(buildingComp != null) {
            this.buildEnt = buildEnt;
            buildBuilding = buildingComp;
            movement.setTarget(buildEnt.getPosition());
            state = EngineerState.Build;
        }
        return this.buildEnt;
    }

    

    private override function init() {
        super.init();

        body = Res.TexturePack.get("EngineerDead");

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
            icon: Res.TexturePack.get("DeconstructActionIcon"),
            callBack: removeCallback,
            active: true
        });

        idleAnimation       = new Animation(Res.TexturePack.get("EngineerIdle"), 1, 0, OriginPoint.Center);
        runAnimation        = new Animation(Res.TexturePack.get("EngineerRun"), 4, 10, OriginPoint.Center);
        interfaceAnimation  = new Animation(Res.TexturePack.get("EngineerInteract"), 4, 10, OriginPoint.Center);
        setAnimation = idleAnimation;

        parentEntity.onMoveEventSubscribe(onMove);
    }

    private override function addedToRoom() {
        super.addedToRoom();
        unitController.moveToEventSubscribe(parentEntity, onMoveTo);
    }

    private override function update() {
        super.update();
        stateMachine();
        animationStates();
    }

    private function stateMachine() {
        switch(state) {
            case EngineerState.Idle:
                selectable.status = idlingStatus;
            case EngineerState.Build:
                selectable.status = buildingStatus;
                if(!room.hasEntity(buildEnt)) {
                    state = EngineerState.Idle;
                    return;
                }

                var d = distance(parentEntity.getPosition(), buildEnt.getPosition());
                if(d < 16) {
                    selectable.status = "Building";
                    buildBuilding.addProgress(buildSpeed);
                    if(buildBuilding.isDone())
                        state = EngineerState.Idle;
                }
            case EngineerState.Repair:
                selectable.status = repairStatus;
            case EngineerState.Destroy:
                selectable.status = destroyingStatus;

                if(!room.hasEntity(destroyEnt)) {
                    state = EngineerState.Idle;
                    return;
                }

                var d = distance(parentEntity.getPosition(), destroyEnt.getPosition());
                if(d < 16) {
                    room.removeEntity(destroyEnt);
                    var buidlingComp: Building = cast destroyEnt.getComponentOfType(Building);
                    ControlPanel.instance.metals += buidlingComp.cost;
                    destroyEnt = null;
                    state = EngineerState.Idle;
                }
        }
    }

    private function animationStates() {
        if(movement.hasStopped()) {
            if(state == EngineerState.Build)
                setAnimation = interfaceAnimation;
            else
                setAnimation = idleAnimation;
        }
        else
            setAnimation = runAnimation;
    }

    private function buildCallback() {
        ControlPanel.instance.queryBuildings(
            (b: ActionButton) -> {
                var buildingAction: BuildingAction = cast b.action;
                var buildingEnt: Entity = new Entity(buildingAction.prefab(buildingAction.cost), 2);
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
        unitController.point(
            (results) ->  {
                for(result in results) {
                    if(result.parentEntity == null)
                        continue;

                    if(result.parentEntity.getComponentOfType(Building) != null) {
                        destroyEnt = result.parentEntity;
                        movement.setTarget(destroyEnt.getPosition());
                        state = EngineerState.Destroy;
                    }

                }
            }
        );
    }

    private function onMoveTo(results: Array<CollisionShape>, pos: Vec2) {
        state = EngineerState.Idle;
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

    private function onMove(to: Vec2, from: Vec2) {
        var angle = hxd.Math.degToRad(Vector.getAngle(to - from));
        idleAnimation.rotation = angle;
        runAnimation.rotation = angle;
        interfaceAnimation.rotation = angle;
    }
}