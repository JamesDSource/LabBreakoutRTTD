import building.BuildingPrefabs;
import hcb.comp.col.Collisions;
import Selectable.Action;
import hcb.comp.col.CollisionShape.Bounds;
import hxd.Res;
import h2d.Object;
import VectorMath;

typedef ActionButton = {
    bounds: Bounds,
    action: Action,
    frame: h2d.Bitmap,
    outline: h2d.filter.Outline,
    ?back: Bool
}

typedef BackAction = {
    > Action,
}

class ControlPanel extends Object {
    public var metals(default, set): Int = 20;

    public static final guiHeight: Float = 96;

    private var font: h2d.Font;

    public var selected(default, set): Array<Selectable> = null;
    private var selectedIndex: Int = 0;
    private var selectedTxt: h2d.Text;
    public var selectedInst(default, set): Selectable = null;
    
    private var yellow: Int = 0xE3FF00;

    private var portraitFrame: h2d.ScaleGrid;
    private var portraitBmp: h2d.Bitmap;

    private var descriptionFrame: h2d.ScaleGrid;
    private var descriptionText: h2d.Text;

    private var actionsFrame: h2d.ScaleGrid;
    private var actionIconFrame: h2d.Tile;
    private final actionButtonMargin: Float = 8;
    private var actionButtons: Array<ActionButton> = [];
    private var queryButtons: Array<ActionButton> = [];
    private var selectedActions: h2d.Object;
    private var queryActions: h2d.Object;
    private var querying: (ActionButton) -> Void = null;

    private var gameInfoFrame: h2d.ScaleGrid;
    private var reconditeCounter: h2d.Text;

    public static final instance: ControlPanel = new ControlPanel();

    private function set_metals(metals: Int): Int {
        this.metals = metals;
        reconditeCounter.text = 'Recondite: $metals';
        return metals;
    }

    private function set_selected(selected: Array<Selectable>): Array<Selectable> {
        this.selected = selected;
        selectedIndex = 0;
        if(selected == null || selected.length == 0) {
            selectedInst = null;
            selectedTxt.text = "";
            portraitBmp.visible = false;
        }
        else {
            selectedInst = selected[selectedIndex];
            selectedTxt.text = '${selectedIndex + 1}/${selected.length}';
            portraitBmp.visible = true;
        }
        return selected;
    }

    private function set_selectedInst(selectedInst: Selectable): Selectable {
        if(this.selectedInst != null) {
            this.selectedInst.outline.color = 0xFFFFFF;
            selectedActions.removeChildren();
            actionButtons = [];
        }
        
        this.selectedInst = selectedInst;
        if(selectedInst == null) {
            portraitBmp.tile = null;
        }
        else {
            portraitBmp.tile = selectedInst.portrait;
            selectedInst.outline.color = yellow;

            convertActionsToButtons(selectedInst.actions, selectedActions, actionButtons);
        }

        return selectedInst;
    }

    private function new() {
        super();
    }

    public function build() {
        font = hxd.res.DefaultFont.get();
        var frameTile: h2d.Tile = Res.TexturePack.get("Frame");
        actionIconFrame = Res.TexturePack.get("ActionIconFrame");
        
        var xPos: Float = 0;

        // * Portraits
        portraitFrame = new h2d.ScaleGrid(frameTile, 8, 8, 8, 8, this);
        portraitFrame.width = guiHeight;
        portraitFrame.height = guiHeight;

        portraitBmp = new h2d.Bitmap(portraitFrame);
        portraitBmp.x = guiHeight/2;
        portraitBmp.y = guiHeight/2;
        portraitBmp.visible = false;
        xPos += guiHeight;

        selectedTxt = new h2d.Text(font, portraitFrame);
        selectedTxt.textAlign = h2d.Text.Align.Left;
        selectedTxt.x = selectedTxt.y = 3;

        // * Description
        descriptionFrame = new h2d.ScaleGrid(frameTile, 8, 8, 8, this);
        descriptionFrame.x = xPos;
        descriptionFrame.width = Room.width*0.2;
        descriptionFrame.height = guiHeight;
        xPos += descriptionFrame.width;

        descriptionText = new h2d.Text(font, descriptionFrame);
        descriptionText.textAlign = h2d.Text.Align.Left;
        descriptionText.x = selectedTxt.y = 3;

        // * Actions
        actionsFrame = new h2d.ScaleGrid(frameTile, 8, 8, 8, this);
        actionsFrame.x = xPos;
        actionsFrame.height = guiHeight;
        actionsFrame.width = Room.width*0.4;
        xPos += actionsFrame.width;

        selectedActions = new h2d.Object(actionsFrame);
        queryActions = new h2d.Object(actionsFrame);

        // * Game info
        gameInfoFrame = new h2d.ScaleGrid(frameTile, 8, 8, 8, this);
        gameInfoFrame.x = xPos;
        gameInfoFrame.height = guiHeight;
        gameInfoFrame.width = Room.width - xPos;

        var infoTextMargin: Float = 15;
        var infoTextPos: Float = 5;
        reconditeCounter = new h2d.Text(font, gameInfoFrame);
        reconditeCounter.textAlign = h2d.Text.Align.Left;
        reconditeCounter.x = infoTextMargin;
        reconditeCounter.y = infoTextPos;
        reconditeCounter.text = 'Recondite: $metals';
    }

    public function offsetSelectedIndex(offset: Int) {
        if(selected == null || selected.length == 0)
            return;

        selectedIndex += offset;
        if(selectedIndex < 0)
            selectedIndex = selected.length - 1;
        if(selectedIndex >= selected.length)
            selectedIndex = 0;

        selectedInst = selected[selectedIndex];
        selectedTxt.text = '${selectedIndex + 1}/${selected.length}';
        
    }

    public function getselectedIndex(): Int {
        return selectedIndex;
    }

    public function update() {
        var buttonsChecking: Array<ActionButton> = querying == null ? actionButtons : queryButtons;
        for(button in buttonsChecking) {
            var icon: h2d.Bitmap = cast button.frame.getChildAt(0);
            var shader = icon.getShader(shader.GreyShader);
            if(button.action.activeCondition == null || button.action.activeCondition()) {
                button.action.active = true;
                shader.active = 0;
            }
            else {
                button.action.active = false;
                shader.active = 1;
            }
        }

        // * Building the description text
        var descText: String = "";
        if(selectedInst != null) {
            descText += '${selectedInst.name}\n${selectedInst.status}\n';
            var health: Health = cast selectedInst.parentEntity.getComponentOfType(Health);
            if(health != null) {
                descText += '${Std.int(health.hp)}/${health.maxHp} Hit Points\n';
            }
        }
        descriptionText.text = descText;
    }

    public function getMouseInputs(mouseX: Float, mouseY: Float) {
        Main.mouseHint.text = "";
        Main.mouseHint.color = new h3d.Vector(1.0, 1.0, 1.0);

        var buttonsChecking: Array<ActionButton> = querying == null ? actionButtons : queryButtons;

        if(querying != null && hxd.Key.isPressed(hxd.Key.ESCAPE)) {
            querying = null;
            queryActions.removeChildren();
            queryButtons = [];
            queryActions.visible = false;
            selectedActions.visible = true;
        }

        for(button in buttonsChecking) {
            var inBounds: Bool = Collisions.pointInAABB(vec2(mouseX, mouseY), button.bounds.min, button.bounds.max);
            
            button.outline.color = 0xFFFFFF;
            if(inBounds && button.action.active) {
                button.outline.size = 1;
                Main.mouseHint.text = button.action.name;

                if(hxd.Key.isDown(hxd.Key.MOUSE_LEFT)) {
                    button.outline.color = yellow;
                }

                if(hxd.Key.isReleased(hxd.Key.MOUSE_LEFT)) {
                    if(querying == null) {
                        button.action.callBack();
                    }
                    else {
                        if(button.back == null || !button.back) {
                            querying(button);
                        }
                        
                        querying = null;
                        queryActions.removeChildren();
                        queryButtons = [];
                        queryActions.visible = false;
                        selectedActions.visible = true;
                    }
                }
            }
            else {
                if(inBounds && button.action.inactiveText != null) {
                    Main.mouseHint.color = new h3d.Vector(1.0, 0.0, 0.0);
                    Main.mouseHint.text = button.action.inactiveText();
                }

                button.outline.size = 0;
            }
        }
    }

    public function query(actions: Array<Action>, callBack: (ActionButton) -> Void) {
        if(querying == null) {
            var tempActions = actions.copy();
            tempActions.resize(Std.int(Math.min(tempActions.length, 17)));
            var backAction: BackAction = {
                name: "Back",
                icon: Res.TexturePack.get("RemoveActionIcon"),
                callBack: () -> {},
                active: true
            }
            tempActions.push(backAction);
            convertActionsToButtons(tempActions, queryActions, queryButtons);
            queryButtons[queryButtons.length - 1].back = true;
            selectedActions.visible = false;
            queryActions.visible = true;
            querying = callBack;
        }
    }

    public function queryBuildings(callBack: (ActionButton) -> Void) {
        var actions: Array<Action> = [];
        for(data in BuildingPrefabs.buildingData) {
            var buildingAction: BuildingAction = {
                name: '${data.name}\n${data.cost}RE',
                icon: data.icon,
                callBack: () -> {},
                active: true,
                activeCondition: () -> {
                    return ControlPanel.instance.metals >= data.cost;
                },
                inactiveText: () -> 'Not Enought Money!\nNeed: ${data.cost}RE',
                cost: data.cost,
                prefab: data.entityPrefab
            }

            actions.push(buildingAction);
        }

        query(actions, callBack);
    }

    private function convertActionsToButtons(actions: Array<Action>, parent: h2d.Object, addTo: Array<ActionButton>) {
        var i: Int = 0;
        for(action in actions) {
            // * Centering the icon
            var aiw: Float = action.icon.width;
            var aih: Float = action.icon.height;
            var pivotOffsets = hcb.Origin.getOriginOffset(hcb.Origin.OriginPoint.Center, vec2(aiw, aih));
            action.icon.dx = pivotOffsets.x;
            action.icon.dy = pivotOffsets.y;

            // * Calculating the position
            var pos: Vec2 = vec2(0, 0);
            pos.x = actionButtonMargin + Math.floor(i/2)*(actionIconFrame.width + actionButtonMargin);
            pos.y = actionsFrame.height/2 + (i%2 == 0 ? -(actionButtonMargin/2 + actionIconFrame.height) : actionButtonMargin/2);

            // * Adding the frame and icon
            var frame: h2d.Bitmap = new h2d.Bitmap(actionIconFrame, parent);
            frame.x = pos.x;
            frame.y = pos.y;
            var icon: h2d.Bitmap = new h2d.Bitmap(action.icon, frame);
            icon.x = frame.tile.width/2;
            icon.y = frame.tile.height/2;
            frame.filter = new h2d.filter.Outline(0, 0xFFFFFF);
            
            var greyShader = new shader.GreyShader();
            greyShader.active = 0;
            icon.addShader(greyShader);
            
            frame.syncPos();
            var frameAbsPos = frame.getAbsPos();
            var framePos: Vec2 = vec2(frameAbsPos.x, frameAbsPos.y);
            var bounds: Bounds = {
                min: framePos,
                max: framePos + vec2(frame.tile.width, frame.tile.height)
            }

            addTo.push({bounds: bounds, action: action, frame: frame, outline: cast frame.filter});
            i++;
        }
    }
}