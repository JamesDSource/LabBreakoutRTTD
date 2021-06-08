import building.BuildingPrefabs;
import hxd.Window;
import hcb.LdtkEntities;
import hcb.Project;

class Main extends hxd.App {
    private var project: hcb.Project;
    private var levelData: LdtkLevelData;

    public static var mouseHint: h2d.Text;

    private override function init() {
        BuildingPrefabs.initBuildingData();

        mouseHint = new h2d.Text(hxd.res.DefaultFont.get());
        mouseHint.textAlign = h2d.Text.Align.Center;
        mouseHint.dropShadow = {
            dx: -1,
            dy: 1,
            color: 0x000000,
            alpha: 1
        };

        ControlPanel.instance.build();
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
        mouseHint.x = project.room.scene.mouseX;
        mouseHint.y = project.room.scene.mouseY;
    }

    //// * Loading assets by generating a pak file
    //private override function loadAssets(onLoad: () -> Void) {
    //    cherry.tools.ResTools.initPakAuto(onLoad, (p) -> trace(p));
    //}

    public static function main() {
        hxd.Res.initLocal();
        new Main();
    }
}