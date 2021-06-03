import hcb.pathfinding.PathfindingGrid;
import hcb.Entity;
import h2d.Scene.ScaleModeAlign;
import hcb.LdtkEntities;
import VectorMath;

class Room extends hcb.Room {
    private var level: LdtkLevelData.LdtkLevelData_Level;
    public var pathfindingGrid(default, null): PathfindingGrid;

    public function new(level: LdtkLevelData.LdtkLevelData_Level) {
        super();
        this.level = level;
    }

    public override function build() {
        drawTo = new h2d.Layers();
        scene.add(drawTo, 0);

        var width = 960;
        var height = 540;

        var levelW: Float = level.pxWid;
        var levelH: Float = level.pxHei;

        var view = level.l_Entities.all_View[0];
        scene.camera.x = view.pixelX;
        scene.camera.y = view.pixelY;

        var guiHeight = height - view.height;

        scene.scaleMode = ScaleMode.LetterBox(width, height, false, ScaleModeAlign.Center, ScaleModeAlign.Center);

        // * Control Panel
        var panel = ControlPanel.instance;
        panel.x = view.pixelX;
        panel.y = view.pixelY + view.height;
        drawTo.add(panel, 1);
        var g = new h2d.Graphics(panel);
        g.beginFill(0xFFFFFF);
        g.drawRect(0, 0, width, guiHeight);
        g.endFill();

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
        var playerContollerEnt: Entity = new Entity(Prefabs.generatePlayerController());
        addEntity(playerContollerEnt);
        LdtkEntities.ldtkAddEntities(this, cast level.l_Entities.getAllUntyped(), 0);
    }
}