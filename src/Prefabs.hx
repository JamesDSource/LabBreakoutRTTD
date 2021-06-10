import hcb.Entity;
import hcb.comp.anim.Animation;
import unit.*;
import enemy.*;
import hcb.comp.anim.AnimationPlayer;
import hxd.Res;
import hcb.Origin.OriginPoint;
import hcb.comp.*;
import hcb.comp.col.*;
import LdtkLevelData.Enum_UnitType;
class Prefabs {
    public static function generatePlayerController(): Array<Component> {

        return [
            new UnitController("Controller")
        ];
    }

    public static function generateUnit(?ent: ldtk.Entity): Array<Component> {
        var entity: LdtkLevelData.Entity_Unit = cast ent;
        var color: Int = 0;
        var portrat: h2d.Tile = null;
        var name: String = "";
        var unitComp: Unit;
        switch(entity.f_UnitType) {
            case Enum_UnitType.Soldier:
                color = 0xFF0000;
                portrat = Res.TexturePack.get("SoldierPortrait");
                name = "Soldier";
                unitComp = new Soldier("Soldier");
            case Enum_UnitType.Scientist:
                color = 0x00FF00;
                portrat = Res.TexturePack.get("ScientistPortrait");
                name = "Scientist";
                unitComp = new Scientist("Scientist");
            case Enum_UnitType.Engineer:
                color = 0x0000FF;
                portrat = Res.TexturePack.get("EngineerPortrait");
                name = "Engineer";
                unitComp = new Engineer("Engineer");
        }

        var col = new CollisionCircle("Collider", 8);
        col.tags.push("Select");
        col.tags.push("Unit");

        var selectable: Selectable = new Selectable(name, portrat);

        return [
            selectable,
            unitComp,
            col,
            new Navigation("Nav"),
            new MoveableUnit("Move", col),
            new Health("Health"),
            new AnimationPlayer("Animation Player")
        ];
    }

    public static function generateWolf(): Array<Component> {
        var wolfComp = new Wolf("Wolf");
        var health = new Health("Hp", 50);
        var navigation = new Navigation("Navi");
        var movement = new MoveableUnit("Move", 2.5, true);
        var animationPlayer = new AnimationPlayer("AnimationPlayer");
        var collisionBox = CollisionPolygon.rectangle("Rect", 25, 8, OriginPoint.Center);
        collisionBox.tags.push("Enemy");
        
        return [
            wolfComp,
            health,
            navigation,
            movement,
            animationPlayer,
            collisionBox
        ];
    }

    public static function generateMonkey(): Array<Component> {
        var monkeyComp = new Monkey("Monkey");
        var health = new Health("Hp", 80);
        var navigation = new Navigation("Navi");
        var movement = new MoveableUnit("Move", 1.5, true);
        var animationPlayer = new AnimationPlayer("AnimationPlayer");
        var collisionCircle = new CollisionCircle("Circle", 8);
        collisionCircle.tags.push("Enemy");
        
        return [
            monkeyComp,
            health,
            navigation,
            movement,
            animationPlayer,
            collisionCircle
        ];
    }

    public static function generateStdBullet(damage: Float = 10, piercing: Int = 1, velocity: Vec2, tagCheck: Array<String>, collider: CollisionShape, tile: h2d.Tile, frames: Int = 1, speed: Int = 10, ?onCollisionWith: (Entity) -> Void): Array<Component> {
        var components: Array<Component> = [];
        
        var projectile = new Projectile("Proj", collider, tagCheck, velocity, piercing, onCollisionWith);

        components.push(collider);
        components.push(projectile);

        if(frames < 2) {
            var spr = new Sprite("Sprite", tile, 0, OriginPoint.Center);
            components.push(spr);
        }
        else {
            var animPlayer = new AnimationPlayer("AnimationPlayer");
            var animation = new Animation(tile, frames, speed, OriginPoint.Center);
            animPlayer.addAnimationSlot("Bullet", 0, animation);
            components.push(animPlayer);
        }

        return components;
    }

    public static function generateExplosive(damage: Float, tagCheck: String): Array<Component> {
        return [
            new AnimationPlayer("Anim"),
            new Explosion("Explosion", tagCheck, damage, 12)
        ];
    }

    public static function generateBody(tile: h2d.Tile): Array<Component> {
        return [
            new Sprite("Spr", tile, 0, OriginPoint.Center)
        ];
    }
}