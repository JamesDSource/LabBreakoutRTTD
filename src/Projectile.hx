import hcb.comp.anim.AnimationPlayer;
import hcb.math.Vector;
import hcb.Entity;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.col.*;
import hcb.comp.*;
import VectorMath;

class Projectile extends Component {
    public var collider: CollisionShape;
    public var tagCheck: String;
    private var velocity: Vec2;
    private var piercing: Int;

    public var damage: Float = 10;
    public var onCollisionWith: (Entity) -> Void;

    private var animationPlayer: AnimationPlayer;
    private var sprite: Sprite;

    private var alreadyDamaged: Array<Entity> = [];

    public function new(name: String, collider: CollisionShape, tagCheck: String, ?velocity: Vec2, piercing: Int = 1, ?onCollisionWith: (Entity) -> Void) {
        super(name);
        this.collider = collider;
        this.tagCheck = tagCheck;
        this.velocity = velocity == null ? vec2(0, 0) : velocity.clone();
        this.piercing = piercing;
        this.onCollisionWith = onCollisionWith == null ? doDamage : onCollisionWith;
    }

    private override function init() {
        parentEntity.onMoveEventSubscribe(onMove);
        animationPlayer = cast parentEntity.getComponentOfType(AnimationPlayer);
        sprite = cast parentEntity.getComponentOfType(Sprite);
    }

    private override function update() {
        parentEntity.move(velocity);

        var results: Array<CollisionInfo> = [];
        room.collisionWorld.getCollisionAt(collider, results, tagCheck);
        for(result in results) {
            var collidingEnt = result.shape2.parentEntity;
            if(collidingEnt == null || alreadyDamaged.contains(collidingEnt))
                continue;

            if(onCollisionWith != null)
                onCollisionWith(collidingEnt);
            
            alreadyDamaged.push(collidingEnt);

            piercing--;
            if(piercing <= 0) {
                parentEntity.remove();
                return;
            }
        }

        if(room.collisionWorld.getCollisionAt(collider, "Static") != null) {
            parentEntity.remove();
            return;
        }
    }

    public function doDamage(entity: Entity) {
        var healthComp: Health = cast entity.getComponentOfType(Health);
        if(healthComp != null) {
            healthComp.offsetHp(-damage);
        }
    }

    private function onMove(to: Vec2, from: Vec2) {
        var ang = hxd.Math.degToRad(Vector.getAngle(to - from));
        if(sprite != null)
            sprite.rotation = ang;

        if(animationPlayer != null) {
            var slot = animationPlayer.getAnimation("Bullet");
            if(slot != null)
                slot.rotation = ang;
        }

        if(Std.isOfType(collider, CollisionPolygon)) {
            var polygon: CollisionPolygon = cast collider;
            polygon.rotation = hxd.Math.radToDeg(ang);
        }
    }
}