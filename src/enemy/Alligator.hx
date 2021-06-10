package enemy;

import hcb.comp.col.Collisions.CollisionInfo;
import hcb.Entity;
import hcb.comp.col.*;
import hcb.math.Vector;
import hxd.Res;
import hcb.comp.anim.Animation;
import VectorMath;

enum AlligatorState {
    Seek;
    Advance;
    Swing;
}

class Alligator extends Enemy {
    private var state: AlligatorState = Seek;
    
    private var collisionPolygon: CollisionPolygon;

    private var runAnimation: Animation;
    private var attackAnimation: Animation;

    private var target: Entity;
    private var prevTargetPos: Vec2 = null;
    private var randomTarget: Entity;

    private final sightRange: Float = 256;
    private final attackRange: Float = 19;
    private var detectionCircle: CollisionCircle;

    private var damage: Float = 20;
    private var swingCoolDown: Float = 60;
    
    private override function init() {
        super.init();
        metalWorth = 50;

        parentEntity.onMoveEventSubscribe(onMove);

        collisionPolygon = cast parentEntity.getComponentOfType(CollisionPolygon);

        runAnimation = new Animation(Res.TexturePack.get("AlligatorMove"), 4, 8, Center);
        attackAnimation = new Animation(Res.TexturePack.get("AlligatorSpin"), 10, 10, Center);
        attackAnimation.onAnimEnd = () -> if(state == Swing) state = Advance;
        attackAnimation.onFrameEventSubscribe(5, swing);
        setAnimation = runAnimation;

        detectionCircle = new CollisionCircle("Circle", sightRange);
    }

    private override function update() {
        super.update();
        stateMachine();
    }

    private function stateMachine() {
        switch(state) {
            case Seek:
                setAnimation = runAnimation;

                if(!room.hasEntity(randomTarget)) {
                    randomTarget = getRandomUnit();
                    if(randomTarget == null)
                        return;

                    movement.clearPath();
                }

                if(movement.hasStopped())
                    movement.setTarget(randomTarget.getPosition());

                detectionCircle.radius = sightRange;
                var results: Array<CollisionInfo> = [];
                room.collisionWorld.getCollisionAt(detectionCircle, results, parentEntity.getPosition(), "Unit");
                room.collisionWorld.getCollisionAt(detectionCircle, results, parentEntity.getPosition(), "Building");
                for(result in results) {
                    var ent = result.shape2.parentEntity;
                    if(ent == null)
                        continue;
                    if(canSee(ent)) {
                        target = ent;
                        state = Advance;
                        break;
                    }
                }
            case Advance:
                setAnimation = runAnimation;

                if(!room.hasEntity(target)) {
                    target = null;
                    state = Seek;
                    return;
                }

                if(prevTargetPos == null || prevTargetPos != target.getPosition()) {
                    movement.setTarget(target.getPosition());
                    prevTargetPos = target.getPosition();
                }

                if(swingCoolDown > 0) {
                    swingCoolDown--;
                    return;
                }

                detectionCircle.radius = attackRange;
                var results: Array<CollisionInfo> = [];
                room.collisionWorld.getCollisionAt(detectionCircle, results, parentEntity.getPosition(), "Unit");
                room.collisionWorld.getCollisionAt(detectionCircle, results, parentEntity.getPosition(), "Building");
                for(result in results) {
                    var ent = result.shape2.parentEntity;
                    if(ent == target) {
                        attackAnimation.currentFrame = 0;
                        state = Swing;
                        return;
                    }
                }
            case Swing:
                setAnimation = attackAnimation;
                movement.clearPath();
        }
    }

    private function swing() {
        swingCoolDown = 60;
        detectionCircle.radius = attackRange;
        var results: Array<CollisionInfo> = [];
        room.collisionWorld.getCollisionAt(detectionCircle, results, parentEntity.getPosition(), "Unit");
        room.collisionWorld.getCollisionAt(detectionCircle, results, parentEntity.getPosition(), "Building");
        for(result in results) {
            var ent = result.shape2.parentEntity;
            if(ent == null)
                continue;
            var hp: Health = cast ent.getComponentOfType(Health);
            if(hp != null)
                hp.offsetHp(-damage);
        }  
    }

    private function onMove(to: Vec2, from: Vec2) {
        var angle = Vector.getAngle(to - from);
        collisionPolygon.rotation = angle;
        runAnimation.rotation = attackAnimation.rotation = hxd.Math.degToRad(angle);
    }
}