import hxd.Window;
import hcb.LdtkEntities;
import hcb.Project;

class Main extends hxd.App {
    private var project: hcb.Project;
    private var levelData: LdtkLevelData;

    private override function init() {
        Window.getInstance().displayMode = DisplayMode.Fullscreen;

        project = new hcb.Project(this);
        levelData = new LdtkLevelData();
        setEntityPrefabs();

        var testRoom: Room = new Room(levelData.all_levels.TestLevel);
        testRoom.build();

        project.room = testRoom;
    }

    public function setEntityPrefabs() {
        LdtkEntities.ldtkEntityPrefabs["Unit"] = Prefabs.generateUnit;
    }

    private override function update(dt: Float) {
        project.update(dt);
    }

    // * Loading assets by generating a pak file
    private override function loadAssets(onLoad: () -> Void) {
        cherry.tools.ResTools.initPakAuto(onLoad, (p) -> trace(p));
    }

    public static function main() {
        new Main();
    }
}