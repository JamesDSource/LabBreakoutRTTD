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
    outline: h2d.filter.Outline
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
    private var selectedActions: h2d.Object;
    private final actionButtonMargin: Float = 8;
    private var actionButtons: Array<ActionButton> = [];

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

            var i: Int = 0;
            for(action in selectedInst.actions) {
                // * Centering the icon
                var aiw: Float = action.icon.width;
                var aih: Float = action.icon.height;
                var pivotOffsets = hcb.Origin.getOriginOffset(hcb.Origin.OriginPoint.Center, vec2(aiw, aih));
                action.icon.dx = pivotOffsets.x;
                action.icon.dy = pivotOffsets.y;

                // * Calculating the position
                var pos: Vec2 = vec2(0, 0);
                pos.x = actionButtonMargin + Math.floor(i/2)*(actionIconFrame.width + actionButtonMargin);
                pos.y = actionsFrame.height/2 + (i%2 == 0 ? actionButtonMargin/2 : -(actionButtonMargin/2 + actionIconFrame.height));

                // * Adding the frame and icon
                var frame: h2d.Bitmap = new h2d.Bitmap(actionIconFrame, selectedActions);
                frame.x = pos.x;
                frame.y = pos.y;
                var icon: h2d.Bitmap = new h2d.Bitmap(action.icon, frame);
                icon.x = frame.tile.width/2;
                icon.y = frame.tile.height/2;
                frame.filter = new h2d.filter.Outline(0, 0xFFFFFF);
                
                frame.syncPos();
                var frameAbsPos = frame.getAbsPos();
                var framePos: Vec2 = vec2(frameAbsPos.x, frameAbsPos.y);
                var bounds: Bounds = {
                    min: framePos,
                    max: framePos + vec2(frame.tile.width, frame.tile.height)
                }

                actionButtons.push({bounds: bounds, action: action, frame: frame, outline: cast frame.filter});
                i++;
            }
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

    public function getMouseInputs(mouseX: Float, mouseY: Float) {
        for(button in actionButtons) {
            var inBounds: Bool = Collisions.pointInAABB(vec2(mouseX, mouseY), button.bounds.min, button.bounds.max);
            
            button.outline.color = 0xFFFFFF;
            if(inBounds) {
                button.outline.size = 1;

                if(hxd.Key.isDown(hxd.Key.MOUSE_LEFT)) {
                    button.outline.color = yellow;
                }
            }
            else {
                button.outline.size = 0;
            }
        }
    }
}