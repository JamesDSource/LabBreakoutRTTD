package building;

import hcb.comp.anim.AnimationPlayer;
import Selectable.Action;
import hxd.Res;
import hcb.comp.*;
import hcb.comp.col.*;

typedef BuildingData = {
    name: String,
    cost: Int,
    entityPrefab: (Int) -> Array<Component> ,
    icon: h2d.Tile
}

typedef BuildingAction = {
    > Action,
    cost: Int,
    prefab: (Int) -> Array<Component>,
}

class BuildingPrefabs {
    public static var buildingData: Array<BuildingData> = [];

    public static function initBuildingData() {
        buildingData = [
            {
                name: "Sentry",
                cost: 20,
                entityPrefab: generateSentry,
                icon: Res.TexturePack.get("SentryIcon")
            }
        ];
    }


    public static function generateSentry(cost: Int): Array<Component> {
        var collider: CollisionCircle = new CollisionCircle("Circle Shape", 8);
        var placeable = new Placeable("Placeable", collider);
        var building = new Building("Sentry", cost);
        var sentry = new Sentry("Sentry");
        var animationPlayer = new AnimationPlayer("Anim Player");
        var health = new Health("Hp");

        return [
            collider,
            placeable,
            building,
            sentry,
            animationPlayer,
            health
        ];
    }
}