package unit;

import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.col.Collisions.Raycast;
import hcb.comp.col.*;
import hcb.math.Vector;
import hcb.Entity;
import hcb.comp.col.CollisionShape;
import hcb.Origin.OriginPoint;
import hcb.comp.anim.Animation;
import hxd.Res;
import Selectable.Action;

enum SoldierState {
    Seek;
    Defend;
    Heal;
}

class Soldier extends Unit {
    private var previousState: SoldierState = SoldierState.Defend;
    private var state(default, set): SoldierState = SoldierState.Defend;

    private var idleAnimation: Animation;
    private var runAnimation: Animation;
    private var shootAnimation: Animation;

    private var healParticlesSystem: h2d.Particles;
    private var healParticles: h2d.Particles.ParticleGroup;

    private var healAmount: Float = 0.03;

    private var target: Entity = null;
    private var bulletVelocity = 8;

    private var detectionCircle: CollisionCircle;

    private var firing: Bool = false;
    private var fireDelay: Int = 30;
    private var fireTimer: Int = 0;

    private final maxRange = 256;

    private final defendingStatus: String = "Defending";
    private final attackingStatus: String = "Attacking";
    private final healingStatus: String = "Healing";

    private function set_state(state: SoldierState): SoldierState {
        if(this.state != state) {
            previousState = this.state;
            this.state = state;

            firing = false;
            healParticles.enable = state == SoldierState.Heal;
            
            switch(state) {
                case SoldierState.Heal:
                    movement.clearPath();
                default:
            }
        }
        return state;
    }

    private override function init() {
        super.init();

        parentEntity.onMoveEventSubscribe(onMove);

        var attackAction: Action = {
            name: "Attack",
            icon: Res.TexturePack.get("FightActionIcon"),
            callBack: attack,
            active: true
        }

        var defendAction: Action = {
            name: "Defend",
            icon: Res.TexturePack.get("DefenseActionIcon"),
            callBack: defend,
            active: true
        }

        var healAction: Action = {
            name: "Heal",
            icon: Res.TexturePack.get("HealActionIcon"),
            callBack: heal,
            active: true
        }

        selectable.actions = [attackAction, defendAction, healAction];

        idleAnimation = new Animation(Res.TexturePack.get("SoldierIdle"), 1, 0, OriginPoint.Center);
        runAnimation = new Animation(Res.TexturePack.get("SoldierRun"), 4, 10, OriginPoint.Center);
        shootAnimation = new Animation(Res.TexturePack.get("SoldierAttack"), 3, 0, OriginPoint.Center);
        shootAnimation.loop = false;
        shootAnimation.onAnimEnd = () -> {
            shootAnimation.speed = 0;
            shootAnimation.currentFrame = 0;
        };
        shootAnimation.onFrameEventSubscribe(1, fire);
        setAnimation = idleAnimation;

        healParticlesSystem = new h2d.Particles();
        healParticlesSystem.load(haxe.Json.parse(Res.HealParticles.getText()), Res.HealParticles.entry.path);
        healParticles = healParticlesSystem.getGroup("Heal");
        healParticles.enable = false;

        detectionCircle = new CollisionCircle("Detection", maxRange);
    }

    private override function addedToRoom() {
        super.addedToRoom();
        unitController.moveToEventSubscribe(parentEntity, onMoveTo);
        room.drawTo.add(healParticlesSystem, 1);
    }

    private override function removedFromRoom() {
        healParticlesSystem.remove();
    }

    private override function update() {
        super.update();
        var pos: Vec2 = parentEntity.getPosition();
        healParticlesSystem.x = pos.x;
        healParticlesSystem.y = pos.y;
        stateMachine();
        animationStates();
    }

    private function stateMachine() {
        switch(state) {
            case Seek:
                selectable.status = attackingStatus;

                if(!room.hasEntity(target)) {
                    var results: Array<CollisionInfo> = [];
                    room.collisionWorld.getCollisionAt(detectionCircle, results, parentEntity.getPosition(), "Enemy");

                    for(result in results) {
                        var testEntity = result.shape2.parentEntity;
                        if(testEntity == null)
                            continue;

                        var ray: Raycast = {
                            origin: parentEntity.getPosition(),
                            castTo: testEntity.getPosition() - parentEntity.getPosition(),
                            infinite: false
                        }
                        
                        if(room.collisionWorld.getCollisionAt(ray, "Static") == null) {
                            target = testEntity;
                            break;
                        }
                    }

                    if(!room.hasEntity(target)) {
                        firing = false;
                        return;
                    }
                }

                var ray: Raycast = {
                    origin: parentEntity.getPosition(),
                    castTo: target.getPosition() - parentEntity.getPosition(),
                    infinite: false
                }
                if(room.collisionWorld.getCollisionAt(ray, "Static") == null && ray.castTo.length() < maxRange) {
                    movement.clearPath();
                    rotate(Vector.getAngle(ray.castTo));
                    firing = true;
                }
                else {
                    movement.setTarget(target.getPosition());
                    firing = false;
                }
                
            case Defend:
                selectable.status = defendingStatus;

                if(!movement.hasStopped()) {
                    return;
                }

                var defenseTarget: Entity = null;
                var results: Array<CollisionInfo> = [];
                room.collisionWorld.getCollisionAt(detectionCircle, results, parentEntity.getPosition(), "Enemy");
                var minDistance: Float = Math.POSITIVE_INFINITY;
                for(result in results) {
                    var testEntity = result.shape2.parentEntity;
                    if(testEntity == null)
                        continue;

                    var ray: Raycast = {
                        origin: parentEntity.getPosition(),
                        castTo: testEntity.getPosition() - parentEntity.getPosition(),
                        infinite: false
                    }
                    
                    if(room.collisionWorld.getCollisionAt(ray, "Static") == null && ray.castTo.length() < minDistance) {
                        defenseTarget = testEntity;
                        minDistance = ray.castTo.length();
                    }
                }

                firing = false;
                if(!room.hasEntity(defenseTarget))
                    return;

                rotate(Vector.getAngle(defenseTarget.getPosition() - parentEntity.getPosition()));
                firing = true;
            
            case Heal:
                selectable.status = healingStatus;

                if(!movement.hasStopped()) {
                    state = previousState;
                    return;
                }
                health.offsetHp(healAmount*Research.soldierHealSpeedMult);
                if(health.hp == health.maxHp) {
                    state = previousState;
                }
        }
    }

    private function animationStates() {
        if(movement.hasStopped()) {
            if(firing) {
                fireTimer--;
                if(fireTimer <= 0) {
                    fireTimer = fireDelay;
                    setAnimation = shootAnimation;
                    shootAnimation.speed = 8;
                }
            }
            else
                setAnimation = idleAnimation;
        }  
        else
            setAnimation = runAnimation;
    }

    private function attack() {
        state = SoldierState.Seek;
    }

    private function defend() {
        state = SoldierState.Defend;
        movement.clearPath();
    }

    private function heal() {
        state = SoldierState.Heal;
    }

    private function onMoveTo(results: Array<CollisionShape>, pos: Vec2) {
        state = SoldierState.Defend;
        for(result in results) {
            if(result.tags.contains("Enemy") && result.parentEntity != null) {
                target = result.parentEntity;
                state = SoldierState.Seek;
            }
        }
    }

    private function onMove(to: Vec2, from: Vec2) {
        var angle = Vector.getAngle(to - from);
        rotate(angle);
    }

    private function rotate(angle: Float) {
        var radAngle = hxd.Math.degToRad(angle);
        idleAnimation.rotation = radAngle;
        runAnimation.rotation = radAngle;
        shootAnimation.rotation = radAngle;
    }

    public function fire() {
        var damage: Float = 15;
        var angle: Float = hxd.Math.radToDeg(shootAnimation.rotation);
        var direction: Vec2 = Vector.angleToVec2(angle, 1);
        var spawnPos: Vec2 = parentEntity.getPosition() + direction*10;
        var velocity: Vec2 = direction*bulletVelocity;
        var collider: CollisionPolygon = CollisionPolygon.rectangle("Collider", 6, 4, OriginPoint.Center);
        var onCollisionWith: (Entity) -> Void = null;
        if(Research.isUnlocked(Research.soldierExplosiveAmmo)) {
            onCollisionWith = (ent) -> {
                var explEnt = new Entity(Prefabs.generateExplosive(damage, "Enemy"), ent.getPosition(), 2);
                room.addEntity(explEnt);
            }
        }

        var bullet = new Entity(
            Prefabs.generateStdBullet(
                damage,
                1,
                velocity,
                "Enemy",
                collider,
                Res.TexturePack.get("Bullet"),
                onCollisionWith
            ),
            spawnPos,
            2
        );

        room.addEntity(bullet);
    }
}