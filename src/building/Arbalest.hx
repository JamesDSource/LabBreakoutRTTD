package building;

import hcb.math.Vector;
import hcb.comp.col.Collisions.Raycast;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.Entity;
import hcb.comp.col.*;
import hcb.Origin.OriginPoint;
import hxd.Res;
import hcb.comp.anim.*;
import hcb.comp.*;

class Arbalest extends Component {
    private var animationPlayer: AnimationPlayer;
    private var building: Building;

    private var crossbow: Animation;
    private var base: Sprite;

    private var target: Entity = null;
    private var damage: Float = 25;
    private var fireDelayTime: Float = 20;
    private var fireDelay: Float = 0;
    private var arrowSpeed: Float = 14;
    
    private var detectionCircle: CollisionCircle;

    private var fireSound: hxd.res.Sound;

    private override function init() {
        animationPlayer = cast parentEntity.getComponentOfType(AnimationPlayer);
        building = cast parentEntity.getComponentOfType(Building);

        base = new Sprite("Base", Res.TexturePack.get("ArbalestBeamerBase"), Center);
        parentEntity.addComponent(base);

        crossbow = new Animation(Res.TexturePack.get("ArbalestBeamerBow"), 3, 0, Center);
        crossbow.onFrameEventSubscribe(2, fire);
        crossbow.onAnimEnd = () -> crossbow.speed = crossbow.currentFrame = 0;
        animationPlayer.addAnimationSlot("Bow", 0, crossbow);

        building.addDrawable(base.bitmap);
        building.addDrawable(crossbow);

        detectionCircle = new CollisionCircle("Detection", 192);

        fireSound = Res.Sounds.Laser;
    }

    private override function update() {
        if(!building.isDone())
            return;

        if(!room.hasEntity(target)) {
            detectionCircle.radius = 192*Research.towerRangeMult;
            var results: Array<CollisionInfo> = []; 
            room.collisionWorld.getCollisionAt(detectionCircle, results, parentEntity.getPosition(), "Enemy");
            
            target = null;
            for(result in results) {
                var ent = result.shape2.parentEntity;
                if(ent != null && canSee(ent)) {
                    target = ent;
                    break;
                }
            }

            if(target == null)
                return;
        }

        var angle = hxd.Math.degToRad(Vector.getAngle(target.getPosition() - parentEntity.getPosition()));
        crossbow.rotation = angle;

        if(fireDelay > 0) {
            fireDelay -= Research.towerFireRateMult;
            return;
        }

        crossbow.speed = 8;
        fireDelay = fireDelayTime;
    }

    private function fire() {
        fireSound.play();
        var angle: Float = hxd.Math.radToDeg(crossbow.rotation);
        var direction: Vec2 = Vector.angleToVec2(angle, 1);
        var spawnPos: Vec2 = parentEntity.getPosition();
        var velocity: Vec2 = direction*arrowSpeed;
        var collider: CollisionPolygon = CollisionPolygon.rectangle("Collider", 32, 4, OriginPoint.Center);

        var bullet = new Entity(
            Prefabs.generateStdBullet(
                damage*Research.towerDamageMult,
                20,
                velocity,
                ["Enemy"],
                collider,
                Res.TexturePack.get("ArbalestBolt"),
                4,
                6
            ),
            spawnPos,
            2
        );

        room.addEntity(bullet);
    }

    private function canSee(entity: Entity) {
        var ray: Raycast = {
            origin: parentEntity.getPosition(),
            castTo: entity.getPosition() - parentEntity.getPosition(),
            infinite: false
        }

        return room.collisionWorld.getCollisionAt(ray, "Static") == null;
    }

    private override function addedToRoom() {
        base.parentOverride = room.drawTo;
    }

    private override function removedFromRoom() {
        parentEntity.removeComponent(base);
    }
}