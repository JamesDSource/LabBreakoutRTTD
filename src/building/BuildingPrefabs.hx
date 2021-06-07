package building;

import Selectable.Action;
import hxd.Res;
import hcb.comp.*;
import hcb.comp.col.*;

typedef BuildingData = {
    name: String,
    cost: Int,
    entityPrefab: (Int) -> Array<Component> 
}

typedef BuildingAction = {
    > Action,
    cost: Int,
    prefab: (Int) -> Array<Component>,
}

class BuildingPrefabs {
    public static final buildingData: Array<BuildingData> = [
        {
            name: "Sentry",
            cost: 20,
            entityPrefab: generateSentry
        }
    ];


    public static function generateSentry(cost: Int): Array<Component> {
        var collider: CollisionCircle = new CollisionCircle("Circle Shape", 8);
        var placeable = new Placeable("Placeable", collider);
        var building = new Building("Sentry", cost);
        var spr = new Sprite("Spr", Res.RemoveActionIcon.toTile());
        building.addDrawable(spr.bitmap);

        return [
            building,
            placeable,
            spr,
            collider
        ];
    }
}