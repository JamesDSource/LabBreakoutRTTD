import hcb.Entity;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.col.CollisionShape;
import hcb.comp.Component;
import VectorMath;

class Projectile extends Component {
    public var collider: CollisionShape;
    public var tagCheck: String;
    private var velocity: Vec2;
    private var piercing: Int;

    public var damage: Float = 10;
    public var onCollisionWith: (Entity) -> Void;

    public function new(name: String, collider: CollisionShape, tagCheck: String, ?velocity: Vec2, piercing: Int = 1, ?onCollisionWith: (Entity) -> Void) {
        super(name);
        this.collider = collider;
        this.tagCheck = tagCheck;
        this.velocity = velocity == null ? vec2(0, 0) : velocity.clone();
        this.piercing = piercing;
        this.onCollisionWith = onCollisionWith == null ? doDamage : onCollisionWith;
    }

    private override function update() {
        parentEntity.move(velocity);

        var results: Array<CollisionInfo> = [];
        room.collisionWorld.getCollisionAt(collider, results, tagCheck);
        for(result in results) {
            var collidingEnt = result.shape2.parentEntity;
            if(collidingEnt == null)
                continue;

            if(onCollisionWith != null)
                onCollisionWith(collidingEnt);

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

    private function doDamage(entity: Entity) {
        var healthComp: Health = cast entity.getComponentOfType(Health);
        if(healthComp != null) {
            healthComp.offsetHp(-damage);
        }
    }
}