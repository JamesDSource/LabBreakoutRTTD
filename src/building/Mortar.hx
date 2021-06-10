package building;

import hcb.Entity;
import hcb.comp.col.CollisionCircle;
import hcb.Origin.OriginPoint;
import hxd.Res;
import hcb.comp.anim.*;
import hcb.comp.*;

class Mortar extends Component {
    private var animationPlayer: AnimationPlayer;
    private var building: Building;

    private var tube: Animation;
    private var base: Sprite;

    private var target: Entity = null;
    private var damage: Float = 10;
    private var fireDelayTime: Float = 20;
    private var fireDelay: Float = 0;
    
    private var detectionCircle: CollisionCircle;

    private override function init() {
        animationPlayer = cast parentEntity.getComponentOfType(AnimationPlayer);
        building = cast parentEntity.getComponentOfType(Building);

        base = new Sprite("Base", Res.TexturePack.get("MortarTowerBase"), Center);
        parentEntity.addComponent(base);

        tube = new Animation(Res.TexturePack.get("MortarTube"), 3, 0, Center);
        tube.rotation = hxd.Math.degToRad(-90);
        tube.onFrameEventSubscribe(2, explode);
        tube.onAnimEnd = () -> tube.speed = tube.currentFrame = 0;
        animationPlayer.addAnimationSlot("Tube", 0, tube);

        building.addDrawable(base.bitmap);
        building.addDrawable(tube);

        detectionCircle = new CollisionCircle("Detection", 192);
    }

    private override function update() {
        if(!building.isDone())
            return;

        if(!room.hasEntity(target)) {
            detectionCircle.radius = 192*Research.towerRangeMult;
            var result = room.collisionWorld.getCollisionAt(detectionCircle, parentEntity.getPosition(), "Enemy");
            if(result != null)
                target = result.shape2.parentEntity;
            else 
                return;
        }

        if(fireDelay > 0) {
            fireDelay -= Research.towerFireRateMult;
            return;
        }

        tube.speed = 8;
        fireDelay = fireDelayTime;
    }

    private function explode() {
        if(!room.hasEntity(target))
            return;

        var explosion = new Entity(Prefabs.generateExplosive(damage*Research.towerDamageMult, "Enemy"), target.getPosition(), 2);
        room.addEntity(explosion);
    }

    private override function addedToRoom() {
        base.parentOverride = room.drawTo;
    }

    private override function removedFromRoom() {
        parentEntity.removeComponent(base);
    }
}