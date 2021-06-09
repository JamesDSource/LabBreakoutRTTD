package building;

import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.col.CollisionCircle;
import hcb.Origin.OriginPoint;
import hxd.Res;
import hcb.comp.anim.*;
import hcb.comp.*;

class FreezeField extends Component {
    private var animationPlayer: AnimationPlayer;
    private var building: Building;

    private var base: Sprite;
    private var top: Sprite;
    private var field: Animation;
    private var initField: Bool = false;

    private var collider: CollisionCircle;

    private override function init() {
        animationPlayer = cast parentEntity.getComponentOfType(AnimationPlayer);
        animationPlayer.layer = 1;
        building = cast parentEntity.getComponentOfType(Building);

        base = new Sprite("Base", Res.TexturePack.get("FreezeFieldBase"), 0, OriginPoint.Center);
        top = new Sprite("Top", Res.TexturePack.get("FreezeFieldTop"), 0, OriginPoint.Center);
        field = new Animation(Res.TexturePack.get("FreezeFieldFrost"), 4, 8, OriginPoint.Center);

        parentEntity.addComponents([base, top]);
        building.addDrawable(base.bitmap);
        building.addDrawable(top.bitmap);

        collider = new CollisionCircle("Collider", 24);
    }

    private override function update() {
        if(building.isDone()) {
            if(!initField) {
                animationPlayer.addAnimationSlot("Frost", 0, field);
                initField = true;
            }

            top.rotation += hxd.Math.degToRad(5);

            var results: Array<CollisionInfo> = [];
            room.collisionWorld.getCollisionAt(collider, results, parentEntity.getPosition(), "Enemy");
            for(result in results) {
                var ent = result.shape2.parentEntity;
                if(ent == null)
                    continue;

                var moveComp: MoveableUnit = cast ent.getComponentOfType(MoveableUnit);
                if(moveComp == null)
                    continue;

                moveComp.tempSpeedMod = 0.2;
            }
        }
    }

    private override function addedToRoom() {
        base.parentOverride = room.drawTo;
    }

    private override function removedFromRoom() {
        parentEntity.removeComponent(base);
    }
}