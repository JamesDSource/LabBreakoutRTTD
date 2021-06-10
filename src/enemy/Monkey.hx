package enemy;

import hcb.comp.col.Collisions.Raycast;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.col.*;
import hcb.math.Vector;
import hcb.Origin.OriginPoint;
import hxd.Res;
import hcb.comp.anim.Animation;
import hcb.Entity;
import hcb.math.Random;
import VectorMath;

enum MonkeyState {
    Seek;
    Advance;
    Attack;
}

class Monkey extends Enemy {
    private var state: MonkeyState = Seek;

    private var dartMonkey: Bool;

    private var target: Entity = null;
    private var prevTargetPos: Vec2 = null;
    private var randomUnit: Entity = null;

    private var runAnimation: Animation;
    private var punchAnimation: Animation;
    private var throwAnimation: Animation;

    private final sightRange: Int = 128;
    private final punchRange: Int = 8;

    private var dartdamage: Float = 15;
    private var punchDamage: Float = 8;

    private var dartVelocity: Float = 4;

    private var detectionCollider: CollisionCircle;

    private override function init() {
        super.init();
        metalWorth = 15;

        parentEntity.onMoveEventSubscribe(onMove);

        dartMonkey = Random.randomRange(0, 100) < 50;

        runAnimation = new Animation(Res.TexturePack.get("MonkeyRun"), 4, 10, OriginPoint.Center);
        punchAnimation = new Animation(Res.TexturePack.get("MonkeyPunch"), 8, 10, OriginPoint.Center);
        punchAnimation.onAnimEnd = () -> if(state == Attack) state = Advance;
        punchAnimation.onFrameEventSubscribe(2, punch);
        punchAnimation.onFrameEventSubscribe(5, punch);
        throwAnimation = new Animation(Res.TexturePack.get("MonkeyThrow"), 6, 10, OriginPoint.Center);
        throwAnimation.onFrameEventSubscribe(5, fire);
        setAnimation = runAnimation;

        detectionCollider = new CollisionCircle("Detection", sightRange);
    }

    private override function update() {
        super.update();
        stateMachine();
    }

    private function stateMachine() {
        switch(state) {
            case Seek:
                setAnimation = runAnimation;

                if(!room.hasEntity(randomUnit)) {
                    randomUnit = getRandomUnit();
                    if(randomUnit == null)
                        return;

                    movement.clearPath();
                }

                if(movement.hasStopped()) {
                    movement.setTarget(randomUnit.getPosition());
                }

                detectionCollider.radius = sightRange;
                
                var results: Array<CollisionInfo> = [];
                room.collisionWorld.getCollisionAt(detectionCollider, results, parentEntity.getPosition(), "Building");
                room.collisionWorld.getCollisionAt(detectionCollider, results, parentEntity.getPosition(), "Unit");
                for(result in results) {
                    if(result.shape2.parentEntity == null)
                        continue;


                    if(canSee(result.shape2.parentEntity)) {
                        target = result.shape2.parentEntity;
                        state = dartMonkey ? MonkeyState.Attack : MonkeyState.Advance;
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

                detectionCollider.radius = punchRange;
                var results: Array<CollisionInfo> = [];
                room.collisionWorld.getCollisionAt(detectionCollider, results, parentEntity.getPosition());
                for(result in results) {
                    if(result.shape2.parentEntity == target) {
                        state = Attack;
                        punchAnimation.currentFrame = 0;
                        return;
                    }
                }
            case Attack:
                if(!room.hasEntity(target)) {
                    target = null;
                    state = Seek;
                    return;
                }

                if(dartMonkey && !movement.hasStopped()) 
                    movement.clearPath();
                
                if(dartMonkey && (!canSee(target) || target.getPosition().distance(parentEntity.getPosition()) > sightRange)) {
                    target = null;
                    return;
                } 

                rotate(Vector.getAngle(target.getPosition() - parentEntity.getPosition()));
                setAnimation = dartMonkey ? throwAnimation : punchAnimation;
        }
    }

    private function fire() {
        var angle: Float = hxd.Math.radToDeg(throwAnimation.rotation);
        var direction: Vec2 = Vector.angleToVec2(angle, 1);
        var spawnPos: Vec2 = parentEntity.getPosition() + direction*4;
        var velocity: Vec2 = direction*dartVelocity;
        var collider: CollisionPolygon = CollisionPolygon.rectangle("Collider", 8, 3, OriginPoint.Center);

        var bullet = new Entity(
            Prefabs.generateStdBullet(
                dartdamage,
                1,
                velocity,
                ["Unit", "Building"],
                collider,
                Res.TexturePack.get("Dart")
            ),
            spawnPos,
            2
        );

        room.addEntity(bullet);
    }

    private function punch() {
        detectionCollider.radius = 2;
        var results: Array<CollisionInfo> = [];
        var pos = parentEntity.getPosition() + Vector.angleToVec2(hxd.Math.radToDeg(punchAnimation.rotation), 4);
        room.collisionWorld.getCollisionAt(detectionCollider, results, pos, "Building");
        room.collisionWorld.getCollisionAt(detectionCollider, results, pos, "Unit");
        for(result in results) {
            if(result.shape2.parentEntity == target) {
                var hp: Health = cast target.getComponentOfType(Health);
                if(hp != null) {
                    hp.offsetHp(-punchDamage);
                }

                break;
            }
        }
    }

    private function onMove(to: Vec2, from: Vec2) {
        var angle = Vector.getAngle(to - from);
        rotate(angle);
    }

    private function rotate(angle: Float) {
        var radAngle: Float = hxd.Math.degToRad(angle);
        runAnimation.rotation = punchAnimation.rotation = throwAnimation.rotation = radAngle;
    }

    private function canSee(entity: Entity): Bool {
        var ray: Raycast = {
            origin: parentEntity.getPosition(),
            castTo: entity.getPosition() - parentEntity.getPosition(),
            infinite: false
        }

        return room.collisionWorld.getCollisionAt(ray, "Static") == null;
    }
}