import hxd.Res;

typedef ResearchData = {
    name: String,
    icon: h2d.Tile,
    pointsNeeded: Int,
    ?required: Array<String>,
    ?onUnlock: () -> Void
}

class Research {
    public static var researchData: Array<ResearchData> = [];
    private static var researchProgress: Map<String, {start: Int, left: Int, unlocked: Bool, ?onUnlock: () -> Void}> = [];

    public static final unitMoveSpeedUpgrade: String        = "+ Unit Move Speed";
    public static final unitMoveSpeedUpgrade2: String       = "++ Unit Move Speed";
    public static final freezeFieldUpgrade: String          = "Freeze Field";
    public static final mortarUpgrade: String               = "Mortar Tower";
    public static final buildingRangeUpgrade: String        = "+ Building Range";
    public static final buildingFireRate: String            = "+ Building Fire Rate";
    public static final engineerRepairSpeedUpgrade: String  = "+ Engineer Repair Speed";
    public static final soldierHealSpeedUpgrade: String     = "+ Soldier Heal Speed";
    public static final arbalestUpgrade: String             = "Arbalest Beamer";
    public static final timeBonusUpgrade: String            = "+ Time Between Waves";
    public static final timeBonusUpgrade2: String           = "++ Time Between Waves";
    public static final unitHpRegenUpgrade: String          = "Unit HP Regen";
    public static final soldierExplosiveAmmo: String        = "Soldier Explosive Ammo";
    public static final buildingDamageUpgrade: String       = "+ Building Damage";
    public static final teleporterUnlock: String            = "Escape Teleporter";

    public static var unitSpeedMult: Float = 1.0;
    public static var repairSpeedMult: Float = 1.0;
    public static var soldierHealSpeedMult: Float = 1.0;
    public static var timeBonus: Float = 0.0;
    public static var towerDamageMult: Float = 1.0;
    public static var towerRangeMult: Float = 1.0;
    public static var towerFireRateMult: Float = 1.0;

    public static function initResearch() {
        // * Add research data
        researchData = [
            {   // * Unit movement
                name: unitMoveSpeedUpgrade,
                icon: Res.TexturePack.get("MoveSpeedUpgradeIcon1"),
                pointsNeeded: 2,
                onUnlock: () -> unitSpeedMult = 1.15
            },
            {   // * Freeze field
                name: freezeFieldUpgrade,
                icon: Res.TexturePack.get("FrostFieldTowerUnlockIcon"),
                pointsNeeded: 3
            },
            {   // * Mortar tower
                name: mortarUpgrade,
                icon: Res.TexturePack.get("MortarTowerUnlockIcon"),
                pointsNeeded: 4,
                required: [freezeFieldUpgrade]
            },
            {   // * Building Range
                name: buildingRangeUpgrade,
                icon: Res.TexturePack.get("TowerRangeUpgradeIcon1"),
                pointsNeeded: 3,
                required: [mortarUpgrade],
                onUnlock: () -> towerRangeMult = 1.15
            },
            {   // * Building Fire Rate
                name: buildingFireRate,
                icon: Res.TexturePack.get("TowerFireRateUpgradeIcon1"),
                pointsNeeded: 3,
                required: [mortarUpgrade],
                onUnlock: () -> towerFireRateMult = 1.3
            },
            {   // * Engineer Repair
                name: engineerRepairSpeedUpgrade,
                icon: Res.TexturePack.get("EngiSpeedUpgradeIcon1"),
                pointsNeeded: 3,
                required: [unitMoveSpeedUpgrade],
                onUnlock: () -> repairSpeedMult = 1.25
            },
            {   // * Soldier heal
                name: soldierHealSpeedUpgrade,
                icon: Res.TexturePack.get("RegenSpeedUpgradeIcon1"),
                pointsNeeded: 3,
                required: [unitMoveSpeedUpgrade],
                onUnlock: () -> soldierHealSpeedMult = 1.25 
            },
            {   // * Arbalest
                name: arbalestUpgrade,
                icon: Res.TexturePack.get("ArbalestTowerUnlockIcon"),
                pointsNeeded: 6,
                required: [soldierHealSpeedUpgrade, mortarUpgrade]
            },
            {   // * Unit movement 2
                name: unitMoveSpeedUpgrade2,
                icon: Res.TexturePack.get("MoveSpeedUpgradeIcon2"),
                pointsNeeded: 6,
                required: [engineerRepairSpeedUpgrade],
                onUnlock: () -> unitSpeedMult = 1.5
            },
            {   // * Time bonus
                name: timeBonusUpgrade,
                icon: Res.TexturePack.get("WaveTimeUpgradeIcon1"),
                pointsNeeded: 5,
                required: [soldierHealSpeedUpgrade],
                onUnlock: () -> timeBonus += 5
            },
            {   // * Time bonus 2
                name: timeBonusUpgrade2,
                icon: Res.TexturePack.get("WaveTimeUpgradeIcon2"),
                pointsNeeded: 7,
                required: [timeBonusUpgrade],
                onUnlock: () -> timeBonus += 10
            },
            {   // * Unit regen
                name: unitHpRegenUpgrade,
                icon: Res.TexturePack.get("UnitRegenUpgradeIcon"),
                pointsNeeded: 5,
                required: [engineerRepairSpeedUpgrade]
            },
            {   // * Explosive Ammo
                name: soldierExplosiveAmmo,
                icon: Res.TexturePack.get("ExplosiveAmmoUpgradeIcon"),
                pointsNeeded: 6,
                required: [soldierHealSpeedUpgrade]
            },
            {   // * Building Damage
                name: buildingDamageUpgrade,
                icon: Res.TexturePack.get("TowerDamageUpgradeIcon1"),
                pointsNeeded: 6,
                required: [arbalestUpgrade, buildingRangeUpgrade, buildingFireRate],
                onUnlock: () -> towerDamageMult = 2
            },
            {   // * Escape Teleporter
                name: teleporterUnlock,
                icon: Res.TexturePack.get("TeleporterUnlockIcon"),
                pointsNeeded: 10,
                required: [soldierExplosiveAmmo, arbalestUpgrade, timeBonusUpgrade2]
            }
        ];

        // * Initializing the unlocked map
        for(data in researchData) {
            researchProgress[data.name] = {
                start: data.pointsNeeded, 
                left: data.pointsNeeded, 
                unlocked: false,
                onUnlock: data.onUnlock
            };
        }
    }

    public static function addProgress(name: String) {
        if(!researchProgress.exists(name)) {
            trace("Research does not exist");
            return;
        }

        var progress = researchProgress[name];
        if(progress.unlocked)
            return;

        progress.left = Std.int(Math.max(0, progress.left - 1));
        if(progress.left == 0) {
            if(progress.onUnlock != null)
                progress.onUnlock();
            
            progress.unlocked = true;
        }
    }

    public static function isUnlocked(name: String): Bool {
        if(!researchProgress.exists(name)) {
            trace("Research does not exist");
            return false;
        }

        return researchProgress[name].unlocked;
    }

    public static function canResearch(data: ResearchData): Bool {
        if(isUnlocked(data.name))
            return false;

        if(data.required != null) {
            for(needed in data.required) {
                if(!isUnlocked(needed))
                    return false;
            }
        }

        return true;
    }

    public static function getProgress(name: String): Float {
        if(!researchProgress.exists(name)) {
            trace("Research does not exist");
            return 0;
        }

        
        return 1 - (researchProgress[name].left/researchProgress[name].start);
    }
}