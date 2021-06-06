import hcb.comp.col.Collisions.CollisionInfo;
import shader.BuildingShader;
import hcb.comp.col.CollisionShape;
import hcb.comp.Component;
import VectorMath;

class Placeable extends Component {
    private var placed(default, set): Bool = false;
    private var collisionShape: CollisionShape;
    private var shader: shader.BuildingShader;
    private var drawables: Array<h2d.Drawable> = [];

    public static final blue = new hxsl.Types.Vec(0.1, 0.1, 0.9);
    public static final red = new hxsl.Types.Vec(0.9, 0.1, 0.1);

    public var placementCanceled: () -> Void = null;

    private function set_placed(placed: Bool): Bool {
        if(this.placed != placed) {
            for(drawable in drawables) {
                if(placed)
                    drawable.removeShader(shader);
                else if(drawable.getShader(BuildingShader) == null) 
                    drawable.addShader(shader);
            }
        }

        this.placed = placed;
        updateable = !placed;
        
        return placed;
    }

    public function new(name: String, collisionShape: CollisionShape) {
        super(name);
        this.collisionShape = collisionShape;
        collisionShape.tags.push("Building");
        shader = new shader.BuildingShader();
    }

    private override function update() {
        shader.offset += 0.1;

        parentEntity.moveTo(vec2(room.scene.mouseX, room.scene.mouseY));

        var colliding: Array<CollisionInfo> = []; 
        room.collisionWorld.getCollisionAt(collisionShape, colliding, "Building");
        room.collisionWorld.getCollisionAt(collisionShape, colliding, "Static");
        var isColliding: Bool = colliding.length > 0;

        shader.color = isColliding ? red : blue;
    }

    private override function removedFromRoom() {
        placementCanceled();
    }

    public function isPlaced(): Bool {
        return placed;
    }

    public function addDrawable(d: h2d.Drawable) {
        d.addShader(shader);
        drawables.push(d);
    }

    public function removeDrawable(d: h2d.Drawable): Bool {
        d.removeShader(shader);
        return drawables.remove(d);
    }
}