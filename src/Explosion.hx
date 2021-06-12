import hcb.Origin.OriginPoint;
import hxd.Res;
import hcb.comp.anim.*;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.col.CollisionCircle;
import hcb.comp.Component;

class Explosion extends Component {
    private var damage: Float;
    private var radius: Float;
    private var tagCheck: String;

    private var animationPlayer: AnimationPlayer;

    private var explosionSound: hxd.res.Sound;

    public function new(name: String, tagCheck: String, damage: Float = 5, radius: Float = 16) {
        super(name);
        this.damage = damage;
        this.radius = radius;
        this.tagCheck = tagCheck;
    }

    private override function init() {
        animationPlayer = cast parentEntity.getComponentOfType(AnimationPlayer);
        var anim = new Animation(Res.TexturePack.get("ExplosiveParticle"), 2, 10, OriginPoint.Center);
        animationPlayer.addAnimationSlot("Main", 0, anim);
        anim.loop = false;
        anim.onAnimEnd = () -> parentEntity.remove();
        explosionSound = Res.Sounds.Explosion;
    }

    private override function addedToRoom() {
        explosionSound.play();

        var collisionCircle: CollisionCircle = new CollisionCircle("Circle", radius);
        var results: Array<CollisionInfo> = [];
        room.collisionWorld.getCollisionAt(collisionCircle, results, parentEntity.getPosition(), tagCheck);

        for(result in results) {
            var ent = result.shape2.parentEntity;
            if(ent == null)
                continue;

            var hpComp: Health = cast ent.getComponentOfType(Health);
            if(hpComp != null)
                hpComp.offsetHp(-damage);
        }
    }
}