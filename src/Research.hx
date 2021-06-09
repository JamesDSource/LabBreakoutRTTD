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

    public static function initResearch() {
        // * Add research data
        researchData = [
            {
                name: "Unit Move Speed",
                icon: Res.TexturePack.get("MoveSpeedUpgradeIcon1"),
                pointsNeeded: 2
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