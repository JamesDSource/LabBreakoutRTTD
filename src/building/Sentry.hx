package building;

import hcb.comp.Sprite;
import hcb.math.Vector;
import hcb.comp.col.Collisions.Raycast;
import hcb.Entity;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.col.*;
import hcb.Origin.OriginPoint;
import hxd.Res;
import hcb.comp.anim.*;
import hcb.comp.Component;

class Sentry extends Component {
    private var building: Building;

    private var animationPlayer: AnimationPlayer;
    private var base: Sprite;
    private var gun: Animation;

    private var detectionShape: CollisionCircle;
    private var target: Entity = null;

    private var bulletVelocity = 8;

    private override function init() {
        building = cast parentEntity.getComponentOfType(Building);

        base = new Sprite("Base", Res.TexturePack.get("StandardTurretBase"), 0, OriginPoint.Center);
        parentEntity.addComponent(base);

        animationPlayer = cast parentEntity.getComponentOfType(AnimationPlayer);
        gun = new Animation(Res.TexturePack.get("StandardTurretGun"), 4, 0, OriginPoint.CenterLeft, -4, 0);
        animationPlayer.addAnimationSlot("Gun", 0, gun);

        building.addDrawable(base.bitmap);
        building.addDrawable(gun);

        detectionShape = new CollisionCircle("Detection", 128);

        gun.onFrameEventSubscribe(1, fire);
    }

    private override function addedToRoom() {
        base.parentOverride = room.drawTo;
    }

    private override function update() {
        if(building.isDone()) {
            if(target == null) {
                var results: Array<CollisionInfo> = [];
                room.collisionWorld.getCollisionAt(detectionShape, results, parentEntity.getPosition(), "Enemy");

                for(result in results) {
                    var rayCast: Raycast = {
                        origin: parentEntity.getPosition(),
                        castTo: result.shape2.getAbsPosition() - parentEntity.getPosition(),
                        infinite: false
                    }

                    if(room.collisionWorld.getCollisionAt(rayCast, "Static") == null) {
                        target = result.shape2.parentEntity;
                    }
                }
                gun.speed = 0;
                gun.currentFrame = 0;
            }
            else if(room.hasEntity(target)){
                var targetPos: Vec2 = target.getPosition();
                gun.rotation = hxd.Math.degToRad(Vector.getAngle(targetPos - parentEntity.getPosition()));
                gun.speed = 8;
            }
            else {
                target = null;
            }
        }
    }

    private override function removedFromRoom() {
        parentEntity.removeComponent(base);
    }

    public function fire() {
        var angle: Float = hxd.Math.radToDeg(gun.rotation);
        var direction: Vec2 = Vector.angleToVec2(angle, 1);
        var spawnPos: Vec2 = parentEntity.getPosition() + direction*10;
        var velocity: Vec2 = direction*bulletVelocity;
        var collider: CollisionPolygon = CollisionPolygon.rectangle("Collider", 6, 4, OriginPoint.Center);

        var bullet = new Entity(
            Prefabs.generateStdBullet(
                10,
                1,
                velocity,
                "Enemy",
                collider,
                Res.TexturePack.get("Bullet")
            ),
            spawnPos,
            2
        );

        room.addEntity(bullet);
    }
}