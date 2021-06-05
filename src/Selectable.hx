import hcb.comp.Component;
import VectorMath;

typedef Action = {
    name: String,
    callBack: () -> Void
}

class Selectable extends Component {
    public var selected(default, set): Bool = false;
    public var portrait(default, null): h2d.Tile;
    public var outline: h2d.filter.Outline;

    private function set_selected(selected: Bool): Bool {
        if(selected != this.selected) {
            outline.color = 0xFFFFFF;
            parentEntity.layers.filter = selected ?  outline : null;
            this.selected = selected;
        }
        return selected;
    }

    public function new(name: String, portrait: h2d.Tile) {
        updateable = false;
        super(name);
        this.portrait = portrait;
        var portraitOffset = hcb.Origin.getOriginOffset(hcb.Origin.OriginPoint.Center, vec2(portrait.width, portrait.height));
        portrait.dx = portraitOffset.x;
        portrait.dy = portraitOffset.y;
        outline = new h2d.filter.Outline(1, 0xFFFFFF, 0.3, true);
    }
}