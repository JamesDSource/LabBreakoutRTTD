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
    public static final freezeFieldUpgrade: String          = "Freeze Field";
    public static final engineerRepairSpeedUpgrade: String  = "+ Engineer Repair Speed";
    public static final soldierHealSpeedUpgrade: String     = "+ Soldier Heal Speed";
    public static final unitHpRegenUpgrade: String          = "Unit HP Regen";
    public static final soldierExplosiveAmmo: String        = "Soldier Explosive Ammo";

    public static var unitSpeedMult: Float = 1.0;
    public static var repairSpeedMult: Float = 1.0;
    public static var soldierHealSpeedMult: Float = 1.0;

    public static function initResearch() {
        // * Add research data
        researchData = [
            {
                name: unitMoveSpeedUpgrade,
                icon: Res.TexturePack.get("MoveSpeedUpgradeIcon1"),
                pointsNeeded: 2,
                onUnlock: () -> unitSpeedMult = 1.15
            },
            {
                name: freezeFieldUpgrade,
                icon: Res.TexturePack.get("FrostFieldTowerUnlockIcon"),
                pointsNeeded: 3
            },
            {
                name: engineerRepairSpeedUpgrade,
                icon: Res.TexturePack.get("EngiSpeedUpgradeIcon1"),
                pointsNeeded: 3,
                required: [unitMoveSpeedUpgrade],
                onUnlock: () -> repairSpeedMult = 1.25
            },
            {
                name: soldierHealSpeedUpgrade,
                icon: Res.TexturePack.get("RegenSpeedUpgradeIcon1"),
                pointsNeeded: 3,
                required: [unitMoveSpeedUpgrade],
                onUnlock: () -> soldierHealSpeedMult = 1.25 
            },
            {
                name: unitHpRegenUpgrade,
                icon: Res.TexturePack.get("UnitRegenUpgradeIcon"),
                pointsNeeded: 5,
                required: [engineerRepairSpeedUpgrade]
            },
            {
                name: soldierExplosiveAmmo,
                icon: Res.TexturePack.get("ExplosiveAmmoUpgradeIcon"),
                pointsNeeded: 6,
                required: [soldierHealSpeedUpgrade]
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