import hcb.pathfinding.PathfindingGrid;
import hcb.Entity;
import h2d.Scene.ScaleModeAlign;
import hcb.LdtkEntities;
import VectorMath;

class Room extends hcb.Room {
    private var level: LdtkLevelData.LdtkLevelData_Level;
    public var pathfindingGrid(default, null): PathfindingGrid;

    public var guiHeight: Float;
    public var view: LdtkLevelData.Entity_View;
    public var divider: Float;

    public static final width: Int = 960;
    public static final height: Int = 540;

    public var playerController: Entity;

    public function new(level: LdtkLevelData.LdtkLevelData_Level) {
        super();
        this.level = level;
    }

    public override function build() {
        drawTo = new h2d.Layers();
        scene.add(drawTo, 0);

        scene.add(Main.mouseHint, 3);

        var levelW: Float = level.pxWid;
        var levelH: Float = level.pxHei;

        view = level.l_Entities.all_View[0];
        scene.camera.x = view.pixelX;
        scene.camera.y = view.pixelY;

        guiHeight = height - view.height;

        scene.scaleMode = ScaleMode.LetterBox(width, height, false, ScaleModeAlign.Center, ScaleModeAlign.Center);

        // * Control Panel
        divider = view.pixelY + view.height;
        var panel = ControlPanel.instance;
        panel.x = view.pixelX;
        panel.y = divider;
        scene.add(panel, 1);

        // * Collisions
        var indexGrid: hcb.IndexGrid.IGrid = hcb.IndexGrid.ldtkTilesConvert(level.l_Collisions);
        var tilePrefabs: Map<Int, (Vec2, Float) -> hcb.comp.col.CollisionShape> = [];
        tilePrefabs[1] = hcb.IndexGrid.slopeBuild.bind(hcb.IndexGrid.SlopeFace.TopLeft,     _, _);
        tilePrefabs[2] = hcb.IndexGrid.slopeBuild.bind(hcb.IndexGrid.SlopeFace.TopRight,    _, _);
        tilePrefabs[4] = hcb.IndexGrid.slopeBuild.bind(hcb.IndexGrid.SlopeFace.BottomLeft,  _, _);
        tilePrefabs[5] = hcb.IndexGrid.slopeBuild.bind(hcb.IndexGrid.SlopeFace.BottomRight, _, _);
        var collisionTiles: Array<hcb.comp.col.CollisionShape> = hcb.IndexGrid.convertToCollisionShapes(indexGrid, null, ["Static"], tilePrefabs);
        for(tile in collisionTiles) {
            collisionWorld.addShape(tile);
        }

        var collisionRender: h2d.TileGroup = level.l_Collisions.render();
        scene.add(collisionRender, 0);

        // * Pathfinding
        var gridSize = vec2(Math.floor(levelW/16), Math.floor(levelH/16));
        pathfindingGrid = new PathfindingGrid(16, gridSize);
        pathfindingGrid.addCollisionShapes(collisionWorld, "Static");

        // * Entities
        playerController = new Entity(Prefabs.generatePlayerController());
        addEntity(playerController);
        LdtkEntities.ldtkAddEntities(this, cast level.l_Entities.getAllUntyped(), 1);

        var wolf = new Entity(Prefabs.generateWolf(), vec2(300, 200));
        addEntity(wolf);
    }

    private override function onUpdate() {
        ControlPanel.instance.update();
    }
}