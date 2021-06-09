package enemy;

import hcb.math.Vector;
import hcb.Origin.OriginPoint;
import hxd.Res;
import unit.Unit;
import hcb.Entity;
import hcb.comp.anim.*;
import hcb.comp.col.*;
import hcb.comp.col.Collisions.Raycast;
import hcb.comp.col.Collisions.CollisionInfo;
import VectorMath;

enum WolfState {
    Dash;
    Advance;
    Attack;
}

class Wolf extends Enemy {
    private var state(default, set): WolfState = WolfState.Dash;

    private var detectionCircle: CollisionCircle;
    private var detectionRadius: Float = 128;
    private var attackRadius: Float = 8;

    private var targetUnit: Entity = null;
    private var prevTargetPos: Vec2 = vec2(0, 0);
    private var randomUnit: Entity = null;

    private var animationPlayer: AnimationPlayer;
    private var runAnimation: Animation;

    private var collisionBox: CollisionPolygon;

    private function set_state(state: WolfState): WolfState {

        if(this.state != state) {
            if(state == WolfState.Dash)
                randomUnit = null;
        }

        this.state = state;
        return state;
    }

    private override function init() {
        super.init();
        parentEntity.onMoveEventSubscribe(onMove);

        detectionCircle = new CollisionCircle("Detection", detectionRadius);
        animationPlayer = cast parentEntity.getComponentOfType(AnimationPlayer);

        runAnimation = new Animation(Res.TexturePack.get("WolfRun"), 4, OriginPoint.Center);
        animationPlayer.addAnimationSlot("Main", 0, runAnimation);

        collisionBox = cast parentEntity.getComponentOfType(CollisionPolygon);
    }

    private override function update() {
        stateMachine();
    }

    private function stateMachine() {
        switch(state) {
            case Dash:
                if(!room.hasEntity(randomUnit)) {
                    randomUnit = getRandomUnit();
                    if(randomUnit == null)
                        return;

                    movement.clearPath();
                }

                if(movement.hasStopped()) {
                    movement.setTarget(randomUnit.getPosition());
                }

                detectionCircle.radius = detectionRadius;
                var results: Array<CollisionInfo> = [];
                room.collisionWorld.getCollisionAt(detectionCircle, results, parentEntity.getPosition(), "Unit");
                
                for(result in results) {
                    var rayCast: Raycast = {
                        origin: parentEntity.getPosition(),
                        castTo: result.shape2.getAbsPosition() - parentEntity.getPosition(),
                        infinite: false
                    }

                    if(room.collisionWorld.getCollisionAt(rayCast, "Static") == null) {
                        targetUnit = result.shape2.parentEntity;
                        movement.clearPath();
                        state = WolfState.Advance;
                    }
                }
            case Advance:
                if(!room.hasEntity(targetUnit)) {
                    state = WolfState.Dash;
                    return;
                }

                if(prevTargetPos != targetUnit.getPosition()) 
                    movement.setTarget(targetUnit.getPosition());
            case Attack:
        }
    }

    private function getRandomUnit(): Entity {
        var allEntites = room.getEntities();

        for(entity in allEntites) {
            if(entity.getComponentOfType(Unit) != null) {
                return entity;
            }
        }

        return null;
    }

    private function onMove(to: Vec2, from: Vec2) {
        var ang = Vector.getAngle(to - from);
        runAnimation.rotation = hxd.Math.degToRad(ang);
        collisionBox.rotation = ang;
    }
}