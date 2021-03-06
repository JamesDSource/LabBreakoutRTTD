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
    icon: h2d.Tile,
    ?researchNeeded: String
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
                cost: 80,
                entityPrefab: generateSentry,
                icon: Res.TexturePack.get("SentryIcon")
            },
            {
                name: "Freeze Feild",
                cost: 100,
                entityPrefab: generateFreezeField,
                icon: Res.TexturePack.get("FrostFieldIcon"),
                researchNeeded: Research.freezeFieldUpgrade
            },
            {
                name: "Mortar Tower",
                cost: 150,
                entityPrefab: generateMortar,
                icon: Res.TexturePack.get("MortarIcon"),
                researchNeeded: Research.mortarUpgrade
            },
            {
                name: "Arbalest Beamer",
                cost: 200,
                entityPrefab: generateArbalest,
                icon: Res.TexturePack.get("ArbalestTowerIcon"),
                researchNeeded: Research.arbalestUpgrade
            },
            {
                name: "Escape Teleporter",
                cost: 1000,
                entityPrefab: generateTeleporter,
                icon: Res.TexturePack.get("TeleporterIcon"),
                researchNeeded: Research.teleporterUnlock
            }
        ];
    }


    public static function generateBuilding(cost: Int, hp: Float, radius: Float): Array<Component> {
        var collider: CollisionCircle = new CollisionCircle("Circle Shape", radius);
        var placeable = new Placeable("Placeable", collider);
        var building = new Building("Tower", cost);
        var animationPlayer = new AnimationPlayer("Anim Player");
        var health = new Health("Hp", hp);
        collider.tags.push("Building");

        return [
            collider,
            placeable,
            building,
            animationPlayer,
            health
        ];
    }

    public static function generateSentry(cost: Int): Array<Component> {
        var components = generateBuilding(cost, 70, 8);
        var sentry = new Sentry("Sentry");
        components.push(sentry);
        return components;
    }

    public static function generateFreezeField(cost: Int): Array<Component> {
        var components = generateBuilding(cost, 100, 9);
        var freezeField = new FreezeField("Field");
        components.push(freezeField);
        return components;
    }

    public static function generateMortar(cost: Int): Array<Component> {
        var components = generateBuilding(cost, 10, 12);
        var mortar = new Mortar("Mortar");
        components.push(mortar);
        return components;
    }

    public static function generateArbalest(cost: Int): Array<Component> {
        var components = generateBuilding(cost, 60, 8);
        var arbalest = new Arbalest("Arbalest");
        components.push(arbalest);
        return components;
    }

    public static function generateTeleporter(cost: Int): Array<Component> {
        var components = generateBuilding(cost, 10000, 8);
        var teleporter = new Teleporter("Teleporter");
        components.push(teleporter);
        return components;
    }
}