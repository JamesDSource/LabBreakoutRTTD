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

    private override function init() {
        building = cast parentEntity.getComponentOfType(Building);

        base = new Sprite("Base", Res.TexturePack.get("StandardTurretBase"), 0, OriginPoint.Center);
        parentEntity.addComponent(base);

        animationPlayer = cast parentEntity.getComponentOfType(AnimationPlayer);
        gun = new Animation(Res.TexturePack.get("StandardTurretGun"), 4, 0, OriginPoint.BottomCenter, 0, 4);
        animationPlayer.addAnimationSlot("Gun", 0, gun);

        building.addDrawable(base.bitmap);
        building.addDrawable(gun);

        detectionShape = new CollisionCircle("Detection", 10);
    }

    private override function addedToRoom() {
        base.parentOverride = room.drawTo;
    }

    private override function update() {
        if(building.isDone()) {
            
            if(target == null) {
                var results: Array<CollisionInfo> = [];
                room.collisionWorld.getCollisionAt(detectionShape, results, "Enemy");

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
            }
            else if(room.hasEntity(target)){
                var targetPos: Vec2 = target.getPosition();
                gun.rotation = Vector.getAngle(targetPos - parentEntity.getPosition());
            }
            else {
                target = null;
            }
        }
    }
}