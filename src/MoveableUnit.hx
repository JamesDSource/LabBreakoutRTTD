import unit.Unit;
import hcb.comp.col.CollisionShape;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.col.CollisionCircle;
import hcb.pathfinding.PathfindingGrid;
import hcb.comp.*;
import VectorMath;

class MoveableUnit extends Component {
    public var baseSpeed: Float;
    public var movementSpeed(get, null): Float;
    public var tempSpeedMod: Float = 1.0;

    public var roomExt: Room = null;
    private var pathfindingGrid: PathfindingGrid = null;
    private var navigation: Navigation;
    private final closeEnough: Float = 1.5;
    private final closeEnoughTarget: Float = 6;

    private var target: Vec2 = null;
    private var path: Array<Vec2> = null;
    private var pathIndex: Int = 0;
    private var stopped: Bool = true;

    private var detectionCircle: CollisionCircle;
    private var detectionRadius: Float;

    private var pushAwayForce: Float = 0.5;

    private var collider: CollisionShape;

    private function get_movementSpeed(): Float {
        var spd = baseSpeed;
        if(parentEntity.getComponentOfType(Unit) != null)
            spd *= Research.unitSpeedMult;
        return spd*tempSpeedMod;
    }

    public function new(name: String, movementSpeed: Float = 2, detectionRadius: Float = 16, ?collider: CollisionShape) {
        super(name);
        this.baseSpeed = movementSpeed;
        this.detectionRadius = detectionRadius;
        this.collider = collider;
    }

    private override function init() {
        navigation = cast parentEntity.getComponentOfType(Navigation);
        detectionCircle = new CollisionCircle("Detection", detectionRadius);
    }

    private override function addedToRoom() {
        roomExt = cast room;
        pathfindingGrid = roomExt.pathfindingGrid;
    }

    private override function removedFromRoom() {
        roomExt = null;
        pathfindingGrid = null;
    }

    private override function update() {
        var pos = parentEntity.getPosition();

        if(!stopped) {
            var collisions: Array<CollisionInfo> = [];
            room.collisionWorld.getCollisionAt(detectionCircle, collisions, pos, "Unit");
            for(collision in collisions) {
                if(collision.shape2.parentEntity == parentEntity)
                    continue;

                var movementComp: MoveableUnit = cast collision.shape2.parentEntity.getComponentOfType(MoveableUnit);
                if(movementComp != null) {
                    if(movementComp.hasStopped() && movementComp.getTarget() != null && movementComp.getTarget() == target) {
                        path = null;
                        stopped = true;
                    }
                    else if(!movementComp.hasStopped()) {
                        var dir: Vec2 = normalize(pos - movementComp.parentEntity.getPosition());
                        parentEntity.move(dir*pushAwayForce);
                    }
                }
            }
        }

        if(path != null && path.length > 0) {
            var nextTarget = path[pathIndex];
            if(nextTarget.distance(pos) <= (pathIndex == path.length - 1 ? closeEnoughTarget : closeEnough)) {
                pathIndex++;
                if(pathIndex == path.length) {
                    path = null;
                    stopped = true;
                }
            }
            else {
                if(nextTarget.distance(pos) < movementSpeed)
                    parentEntity.moveTo(nextTarget);
                else {
                    var dir = normalize(nextTarget - pos);
                    parentEntity.move(dir*movementSpeed);
                }
            }
        }
        else {
            stopped = true;
            path = null;
        }

        if(collider != null) {
            var collisionInfo: CollisionInfo = room.collisionWorld.getCollisionAt(collider, "Static");
            if(collisionInfo != null) {
                parentEntity.move(-collisionInfo.normal*collisionInfo.depth);
            }
        }

        tempSpeedMod = 1.0;
    }

    public function setTarget(target: Vec2) {
        if(pathfindingGrid == null || (path != null && this.target == target))
            return;

        if(target == null) {
            target = null;
            path = null;
            stopped = true;
        }
        else {
            this.target = target.clone();
            path = navigation.getPathTo(pathfindingGrid, target, true);
            stopped = false;
        }

        pathIndex = 0;
        
    }

    public function getTarget(): Vec2 {
        return target == null ? null : target.clone();
    }
    
    public function hasStopped(): Bool {
        return stopped;
    }

    public function clearPath() {
        path = null;
        pathIndex = 0;
        stopped = true;
    }
}