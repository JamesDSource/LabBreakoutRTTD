import unit.Scientist;
import unit.Engineer;
import hxd.Window;
import h3d.Engine;
import hxd.Key;
import unit.Unit;
import hxd.Res;
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

    public var units(default, null): Array<Entity> = [];

    public var playerController: Entity;

    private var gameOver: Bool = false;
    private var pausedText: h2d.Text;
    public var pausedMessage: String = "Game Paused";

    private override function set_paused(paused:Bool):Bool {
        drawTo.filter = paused ? new h2d.filter.Blur() : null;
        pausedText.text = paused ? pausedMessage + "\nPress Q to exit" : "";
        return super.set_paused(paused);
    }

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

        // * Wave controller
        var spawns: Array<Vec2> = [];
        for(spawner in level.l_Entities.all_Spawner) {
            spawns.push(vec2(spawner.pixelX, spawner.pixelY));
        }
        WaveController.startWaves(this, spawns);

        // * Collisions
        var indexGrid: hcb.IndexGrid.IGrid = hcb.IndexGrid.ldtkTilesConvert(level.l_Collisions);
        var tilePrefabs: Map<Int, (Vec2, Float) -> hcb.comp.col.CollisionShape> = [];
        tilePrefabs[3] = hcb.IndexGrid.slopeBuild.bind(hcb.IndexGrid.SlopeFace.TopLeft,     _, _);
        tilePrefabs[4] = hcb.IndexGrid.slopeBuild.bind(hcb.IndexGrid.SlopeFace.TopRight,    _, _);
        tilePrefabs[9] = hcb.IndexGrid.slopeBuild.bind(hcb.IndexGrid.SlopeFace.BottomLeft,  _, _);
        tilePrefabs[10] = hcb.IndexGrid.slopeBuild.bind(hcb.IndexGrid.SlopeFace.BottomRight, _, _);
        var collisionTiles: Array<hcb.comp.col.CollisionShape> = hcb.IndexGrid.convertToCollisionShapes(indexGrid, null, ["Static"], tilePrefabs);
        for(tile in collisionTiles) {
            collisionWorld.addShape(tile);
        }

        var floorRender: h2d.TileGroup = level.l_Floor.render();
        drawTo.add(floorRender, 0);

        var collisionRender: h2d.TileGroup = level.l_Collisions.render();
        drawTo.add(collisionRender, 3);

        // * Pathfinding
        var gridSize = vec2(Math.floor(levelW/16), Math.floor(levelH/16));
        pathfindingGrid = new PathfindingGrid(16, gridSize);
        pathfindingGrid.addCollisionShapes(collisionWorld, "Static");

        // * Entities
        playerController = new Entity(Prefabs.generatePlayerController());
        addEntity(playerController);
        LdtkEntities.ldtkAddEntities(this, cast level.l_Entities.getAllUntyped(), 1);

        // * Pause message
        var f = hxd.res.DefaultFont.get();
        pausedText = new h2d.Text(f);
        pausedText.textAlign = h2d.Text.Align.Center;
        pausedText.scaleX = pausedText.scaleY = 3;
        pausedText.x = view.pixelX + view.width/2;
        pausedText.y = view.pixelY + view.height/2;
        scene.add(pausedText, 5);
    }

    private override function onUpdate() {
        ControlPanel.instance.update();
        //collisionWorld.representShapes(drawTo, 5);

        if(Key.isPressed(Key.ESCAPE) && !gameOver)
            paused = !paused;

        if(paused && Key.isPressed(Key.Q)) {
            Main.mainMenu.rebuild();
            project.room = Main.mainMenu;
        }
            
    }

    private override function entityAdded(entity: Entity) {
        if(entity.getComponentOfType(Unit) != null)
            units.push(entity);
    }

    private override function entityremoved(entity:Entity) {
        if(entity.getComponentOfType(Unit) != null) {
            units.remove(entity);

            var engineers: Int = 0;
            var scientists: Int = 0;
            for(unit in units) {
                if(unit.getComponentOfType(Engineer) != null)
                    engineers++;
                if(unit.getComponentOfType(Scientist) != null)
                    scientists++;
            }

            if(engineers == 0 || scientists == 0) {
                gameOverMessage("Game Over\nAll Essential Units Lost");
            }
        }
    }

    public function gameOverMessage(message: String) {
        gameOver = true;
        pausedMessage = message;
        paused = true;
    }
}