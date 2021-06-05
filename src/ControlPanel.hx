import hxd.Res;
import h2d.Object;

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
        }

        return selectedInst;
    }

    private function new() {
        super();
    }

    public function build() {
        font = hxd.res.DefaultFont.get();
        var frameTile: h2d.Tile = Res.Frame.toTile();
        
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
        actionsFrame.width = Room.width - xPos;
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
}