import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.col.CollisionShape;
import hcb.comp.Component;
import VectorMath;

class Placeable extends Component {
    private var placed(default, set): Bool = false;
    private var canPlace: Bool = false;
    private var collisionShape: CollisionShape;

    public var placementCanceled: () -> Void = null;
    public var onPlaced: (Vec2) -> Void = null;

    private var prevLayer: Int;

    private function set_placed(placed: Bool): Bool {
        if(this.placed != placed) {
            parentEntity.layer = placed ? prevLayer : 2;
            parentEntity.parentOverride = placed ? null : room.scene;
        }

        this.placed = placed;
        updateable = !placed;
        
        return placed;
    }

    public function new(name: String, collisionShape: CollisionShape) {
        super(name);
        this.collisionShape = collisionShape;
    }

    private override function init() {
        prevLayer = parentEntity.layer;
    }

    private override function update() {
        parentEntity.moveTo(vec2(room.scene.mouseX, room.scene.mouseY));

        var colliding: Array<CollisionInfo> = []; 
        room.collisionWorld.getCollisionAt(collisionShape, colliding, "Building");
        room.collisionWorld.getCollisionAt(collisionShape, colliding, "Static");
        var isColliding: Bool = colliding.length > 0;

        canPlace = !isColliding;
    }

    private override function addedToRoom() {
        parentEntity.layer = 2;
        parentEntity.parentOverride = room.scene;
    }

    private override function removedFromRoom() {
        if(!placed)
            placementCanceled();
    }

    public function placeAttempt(): Bool {
        if(!canPlace)
            return false;

        placed = true;
        onPlaced(parentEntity.getPosition());
        return true;
    }

    public function isPlaced(): Bool {
        return placed;
    }

    public function canBePlaced(): Bool {
        return canPlace;
    }
 
}