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

    private var runAnimation: Animation;
    private var attackAnimation: Animation;

    private var collisionBox: CollisionPolygon;

    private var damage: Float = 5;

    

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

        runAnimation = new Animation(Res.TexturePack.get("WolfRun"), 4, OriginPoint.Center);
        attackAnimation = new Animation(Res.TexturePack.get("WolfAttack"), 3, 6, OriginPoint.Center);
        attackAnimation.onFrameEventSubscribe(2, attack);
        attackAnimation.onAnimEnd = () -> if(state == WolfState.Attack) state = WolfState.Advance;
        animationPlayer.addAnimationSlot("Main", 0);
        setAnimation = runAnimation;

        collisionBox = cast parentEntity.getComponentOfType(CollisionPolygon);
    }

    private override function update() {
        stateMachine();
        animationStates();
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

                detectionCircle.radius = attackRadius;
                var results: Array<CollisionInfo> = [];
                room.collisionWorld.getCollisionAt(detectionCircle, results, parentEntity.getPosition(), "Unit");
                for(result in results) {
                    if(result.shape2.parentEntity == targetUnit) {
                        state = WolfState.Attack;
                        attackAnimation.currentFrame = 0;
                        break;
                    }
                }
            case Attack:
                movement.clearPath();
                if(targetUnit != null) {
                    var ang = Vector.getAngle(targetUnit.getPosition() - parentEntity.getPosition());
                    rotate(ang);
                }
        }
    }

    private function attack() {
        detectionCircle.radius = 2;
        var pos = parentEntity.getPosition() + Vector.angleToVec2(collisionBox.rotation, 13);
        var result = room.collisionWorld.getCollisionAt(detectionCircle, pos, "Unit");
        if(result != null && result.shape2.parentEntity != null) {
            var healthComp: Health = cast result.shape2.parentEntity.getComponentOfType(Health);
            if(healthComp != null)
                healthComp.offsetHp(-damage);
        }
    }

    private function animationStates() {
        if(state == WolfState.Attack) 
            setAnimation = attackAnimation;
        else 
            setAnimation = runAnimation;
    }

    private function onMove(to: Vec2, from: Vec2) {
        var ang = Vector.getAngle(to - from);
        rotate(ang);
    }

    private function rotate(angle: Float) {
        var radAngle = hxd.Math.degToRad(angle);
        runAnimation.rotation = radAngle;
        attackAnimation.rotation = radAngle;
        collisionBox.rotation = angle;
    }
}