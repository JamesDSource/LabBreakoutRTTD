package building;

import hcb.comp.*;
import hcb.comp.col.*;

typedef BuildingData = {
    name: String,
    cost: Int,
    entityPrefab: (Int) -> Array<Component> 
}

class BuildingPrefabs {
    public static function generateSentry(cost: Int): Array<Component> {
        var collider: CollisionCircle = new CollisionCircle("Circle Shape", 8);

        return [
            new Building("Sentry", cost),
            new Placeable("Placeable", collider),
            collider
        ];
    }
}