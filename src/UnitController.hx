import hxd.Window;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.col.*;
import hcb.comp.col.CollisionShape.Bounds;
import hxd.Key;
import VectorMath;


enum ControllerMode {
    Select;
    Place;
}

class UnitController extends hcb.comp.Component {
    private var mode: ControllerMode = ControllerMode.Select;

    private var g: h2d.Graphics;
    private var selected: Array<Selectable> = [];

    private var initialDragPos: Vec2 = null;
    private var selectionBounds: Bounds = null;
    private var dragging: Bool = false;
    private final dragThreshold: Int = 10;

    private var roomExt: Room = null;

    public override function init() {
        g = new h2d.Graphics();
    }
    
    private override function addedToRoom() {
        room.scene.add(g, 1);
        roomExt = cast room;
    }

    private override function update() {
        var mousePos: Vec2 = vec2(room.scene.mouseX, room.scene.mouseY);
        if(dragging)
            mousePos.y = Math.min(mousePos.y, roomExt.divider - 1);
            // ^ If dragging, clamp the mouse position to the divider

        if(mousePos.y >= roomExt.divider) {
            ControlPanel.instance.getMouseInputs(mousePos.x, mousePos.y);
        }
        else {
            getSelectionInputs(mousePos);

            if(Key.isPressed(Key.MOUSE_RIGHT)) {
                for(selectedUnit in selected) {
                    var movementComp: MoveableUnit = cast selectedUnit.parentEntity.getComponentOfType(MoveableUnit);
                    if(movementComp != null) {
                        movementComp.setTarget(mousePos);
                    }
                }
            }
        }

        if(Key.isPressed(Key.MOUSE_WHEEL_UP)) {
            ControlPanel.instance.offsetSelectedIndex(1);
        }
        else if(Key.isPressed(Key.MOUSE_WHEEL_DOWN)) {
            ControlPanel.instance.offsetSelectedIndex(-1);
        }
        
        
        // * Drawing the selection bounds
        g.clear();
        if(selectionBounds != null) {
            g.x = selectionBounds.min.x;
            g.y = selectionBounds.min.y;
            var w = selectionBounds.max.x - selectionBounds.min.x;
            var h = selectionBounds.max.y - selectionBounds.min.y;
            g.lineStyle(2, 0xFFFFFF);
            g.beginFill(0xFFFFFF, 0.2);
            g.drawRect(0, 0, w, h);

            if(Key.isReleased(Key.MOUSE_LEFT)) {
                selectionBounds = null;
            }
        }
    }

    private function getSelectionInputs(mousePos: Vec2) {
        if(Key.isPressed(Key.ESCAPE))
            unselectAll();

        // * On pressed
        if(Key.isPressed(Key.MOUSE_LEFT)) 
            initialDragPos = mousePos.clone();

        // * On released
        if(Key.isReleased(Key.MOUSE_LEFT)) {
            if(!Key.isDown(Key.SHIFT))
                unselectAll();
            
            if(selectionBounds == null) {
                var shapesCollided: Array<CollisionShape> = [];
                room.collisionWorld.getCollisionAt(mousePos, shapesCollided, "Select");

                for(shape in shapesCollided) {
                    var unitComp: Selectable = cast shape.parentEntity.getComponentOfType(Selectable);
                    if(unitComp != null) {
                        unitComp.selected = true;
                        selected.push(unitComp);
                        break;
                    }
                }
            }
            else {
                var w = selectionBounds.max.x - selectionBounds.min.x;
                var h = selectionBounds.max.y - selectionBounds.min.y;
                var collisionShape: CollisionAABB = new CollisionAABB("Tester", w, h);
                var output: Array<CollisionInfo> = [];
                room.collisionWorld.getCollisionAt(collisionShape, output, selectionBounds.min, "Select");
                for(info in output) {
                    var unitComp: Selectable = cast info.shape2.parentEntity.getComponentOfType(Selectable);
                    if(unitComp != null) {
                        unitComp.selected = true;
                        selected.push(unitComp);
                    }
                }
            }

            if(selected.length > 0)
                ControlPanel.instance.selected = selected;
            else 
                ControlPanel.instance.selected = null;
        }

        // * On held
        if(Key.isDown(Key.MOUSE_LEFT)) {
            if(initialDragPos != null && mousePos.distance(initialDragPos) > dragThreshold) 
                dragging = true;

            if(dragging) {
                selectionBounds = {
                    min: vec2(Math.min(initialDragPos.x, mousePos.x), Math.min(initialDragPos.y, mousePos.y)),
                    max: vec2(Math.max(initialDragPos.x, mousePos.x), Math.max(initialDragPos.y, mousePos.y))
                }
            }
        }
        else {
            initialDragPos = null;
            selectionBounds = null;
            dragging = false;
        }
    }

    private function unselectAll() {
        for(unit in selected) {
            unit.selected = false;
        }

        selected = [];
    }
}