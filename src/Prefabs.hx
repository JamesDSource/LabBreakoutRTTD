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
        switch(entity.f_UnitType) {
            case Enum_UnitType.Soldier:
                color = 0xFF0000;
                portrat = Res.TexturePack.get("SoldierPortrait");
                name = "Soldier";
            case Enum_UnitType.Scientist:
                color = 0x00FF00;
                portrat = Res.TexturePack.get("ScientistPortrait");
                name = "Scientist";
            case Enum_UnitType.Engineer:
                color = 0x0000FF;
                portrat = Res.TexturePack.get("EngineerPortrait");
                name = "Engineer";
        }

        var col = new CollisionCircle("Collider", 8);
        col.tags.push("Select");
        col.tags.push("Unit");

        var selectable: Selectable = new Selectable(name, portrat);
        selectable.actions.push({
            name: "Build",
            icon: Res.TexturePack.get("BuildActionIcon"),
            callBack: () -> trace("Nice 1")
        });
        selectable.actions.push({
            name: "Repair",
            icon: Res.TexturePack.get("RepairActionIcon"),
            callBack: () -> trace("Nice 2")
        });
        selectable.actions.push({
            name: "Remove",
            icon: Res.RemoveActionIcon.toTile(),
            callBack: () -> trace("Nice 3")
        });

        return [
            new Sprite("Sprite", h2d.Tile.fromColor(color, 16, 16), 0, OriginPoint.Center),
            selectable,
            col,
            new Navigation("Nav"),
            new MoveableUnit("Move", col),
            new Health("Health")
        ];
    }
}