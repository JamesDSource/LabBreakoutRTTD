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
        switch(entity.f_UnitType) {
            case Enum_UnitType.Soldier:
                color = 0xFF0000;
            case Enum_UnitType.Scientist:
                color = 0x00FF00;
            case Enum_UnitType.Engineer:
                color = 0x0000FF;
        }

        var col = new CollisionCircle("Collider", 8);
        col.tags.push("Select");
        col.tags.push("Unit");

        return [
            new Sprite("Sprite", h2d.Tile.fromColor(color, 16, 16), 0, OriginPoint.Center),
            new Selectable("Selectable"),
            col,
            new Navigation("Nav"),
            new MoveableUnit("Move", col),
            new Health("Health")
        ];
    }
}