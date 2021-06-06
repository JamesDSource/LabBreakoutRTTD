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
}

class ControlPanel extends Object {
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
    private var nameTxt: h2d.Text;

    private var actionsFrame: h2d.ScaleGrid;
    private var actionIconFrame: h2d.Tile;
    private final actionButtonMargin: Float = 8;
    private var actionButtons: Array<ActionButton> = [];
    private var queryButtons: Array<ActionButton> = [];
    private var selectedActions: h2d.Object;
    private var queryActions: h2d.Object;
    private var querying: (ActionButton) -> Void = null;

    private var gameInfoFrame: h2d.ScaleGrid;

    public static final instance: ControlPanel = new ControlPanel();

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
            nameTxt.text = "";
            portraitBmp.tile = null;
        }
        else {
            nameTxt.text = selectedInst.name;
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
        var frameTile: h2d.Tile = Res.Frame.toTile();
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

        nameTxt = new h2d.Text(font, descriptionFrame);
        nameTxt.textAlign = h2d.Text.Align.Left;
        nameTxt.x = selectedTxt.y = 3;

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
        for(button in actionButtons) {
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
    }

    public function getMouseInputs(mouseX: Float, mouseY: Float) {
        Main.mouseHint.text = "";

        var buttonsChecking: Array<ActionButton> = querying == null ? actionButtons : queryButtons;

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
                        querying(button);
                        querying = null;
                        queryActions.removeChildren();
                        queryButtons = [];
                        queryActions.visible = false;
                        selectedActions.visible = true;
                    }
                }
            }
            else {
                button.outline.size = 0;
            }
        }
    }

    public function query(actions: Array<Action>, callBack: (ActionButton) -> Void) {
        if(querying == null) {
            convertActionsToButtons(actions, queryActions, queryButtons);
            selectedActions.visible = false;
            queryActions.visible = true;
            querying = callBack;
        }
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