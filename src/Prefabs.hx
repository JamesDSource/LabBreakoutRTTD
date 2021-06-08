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
            new Sprite("Sprite", h2d.Tile.fromColor(color, 16, 16), 0, OriginPoint.Center),
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
        var health = new Health("Hp", 40);
        var navigation = new Navigation("Navi");
        var movement = new MoveableUnit("Move", 2.5);
        var animationPlayer = new AnimationPlayer("AnimationPlayer");
        
        return [
            wolfComp,
            health,
            navigation,
            movement,
            animationPlayer
        ];
    }
}