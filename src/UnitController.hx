import hcb.Entity;
import hxd.System;
import hxd.Cursor;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.col.*;
import hcb.comp.col.CollisionShape.Bounds;
import hxd.Key;
import VectorMath;


enum ControllerMode {
    Select;
    Place;
    Point;
}

class UnitController extends hcb.comp.Component {
    private var mode(default, set): ControllerMode = ControllerMode.Select;

    private var g: h2d.Graphics;
    private var selected: Array<Selectable> = [];

    private var initialDragPos: Vec2 = null;
    private var selectionBounds: Bounds = null;
    private var dragging: Bool = false;
    private final dragThreshold: Int = 10;

    private var roomExt: Room = null;

    private var placeable: Placeable = null;

    private var pointCallback: (Array<CollisionShape>) -> Void = null;
    private var pointTag: String = null;

    private var moveToEventListeners: Map<Entity, (Array<CollisionShape>, Vec2) -> Void> = [];

    private function set_mode(mode: ControllerMode): ControllerMode {
        this.mode = mode;
        var cursor: Cursor;
        switch(mode) {
            case ControllerMode.Select:
                cursor = Cursor.Default;
            case ControllerMode.Place:
                cursor = Cursor.Hide;
            case ControllerMode.Point:
                cursor = Cursor.Button;
        }
        System.setCursor(cursor);
        return mode;
    }

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

        ControlPanel.instance.getMouseInputs(mousePos.x, mousePos.y);
        stateMachine(mousePos, mousePos.y < roomExt.divider);

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

    private function stateMachine(mousePos: Vec2, inBounds: Bool) {
        switch(mode) {
            case ControllerMode.Select:
                if(placeable != null) {
                    mode = ControllerMode.Place;
                    return;
                }

                if(pointCallback != null) {
                    mode = ControllerMode.Point;
                    return;
                }

                if(inBounds)
                    getSelectionInputs(mousePos);

                if(Key.isPressed(Key.MOUSE_RIGHT) && inBounds) {
                    var results: Array<CollisionShape> = [];
                    room.collisionWorld.getCollisionAt(mousePos, results);
                    for(selectedUnit in selected) {
                        var movementComp: MoveableUnit = cast selectedUnit.parentEntity.getComponentOfType(MoveableUnit);
                        if(movementComp != null) {
                            movementComp.setTarget(mousePos);
                            moveToEventCall(selectedUnit.parentEntity, results, mousePos);
                        }
                    }
                }

            case ControllerMode.Place:
                if(Key.isPressed(Key.ESCAPE)) {
                    room.removeEntity(placeable.parentEntity);
                    placeable = null;
                }

                if(placeable == null) {
                    mode = ControllerMode.Select;
                    return;
                }

                if(pointCallback != null) {
                    room.removeEntity(placeable.parentEntity);
                    placeable = null;
                    mode = ControllerMode.Point;
                    return;
                }

                if(Key.isReleased(Key.MOUSE_LEFT) && inBounds) {
                    if(placeable.placeAttempt()) {
                        placeable = null;
                        mode = ControllerMode.Select;
                        return;
                    }
                }
                
            case ControllerMode.Point:
                if(Key.isPressed(Key.ESCAPE)) {
                    pointCallback = null;
                }

                if(pointCallback == null) {
                    mode = ControllerMode.Select;
                    return;
                }
                
                if(placeable != null) {
                    pointCallback = null;
                    mode = ControllerMode.Place;
                    return;
                }
            
                if(Key.isReleased(Key.MOUSE_LEFT) && inBounds) {
                    var results: Array<CollisionShape> = [];
                    roomExt.collisionWorld.getCollisionAt(mousePos, results, pointTag);
                    pointCallback(results);
                    pointCallback = null;
                    pointTag = null;
                    mode = ControllerMode.Select;
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

            ControlPanel.instance.selected = selected.length > 0 ? selected : null;
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

    public function point(callBack: (Array<CollisionShape>) -> Void, ?tag: String) {
        pointCallback = callBack;
        pointTag = tag;
    }

    public function setPlaceable(ent: hcb.Entity) {
        var comp: Placeable = cast ent.getComponentOfType(Placeable);
        if(comp != null) {
            placeable = comp;
        }
    }

    public function moveToEventSubscribe(ent: Entity, callBack: (Array<CollisionShape>, Vec2) -> Void) {
        moveToEventListeners[ent] = callBack;
    }

    public function moveToEventRemove(ent: Entity): Bool {
        return moveToEventListeners.remove(ent);
    }

    private function moveToEventCall(ent: Entity, result: Array<CollisionShape>, pos: Vec2) {
        if(moveToEventListeners.exists(ent))
            moveToEventListeners[ent](result.copy(), pos.clone());
    }
}