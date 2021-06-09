import hcb.comp.Component;
import VectorMath;

typedef Action = {
    name: String,
    icon: h2d.Tile,
    callBack: () -> Void,
    active: Bool,
    ?activeCondition: () -> Bool,
    ?inactiveText: () -> String
}

class Selectable extends Component {
    public var selected(default, set): Bool = false;
    public var portrait(default, null): h2d.Tile;
    public var outline: h2d.filter.Outline;
    public var actions: Array<Action> = [];

    public var status: String = "Default status";

    private function set_selected(selected: Bool): Bool {
        if(selected != this.selected) {
            outline.color = 0xFFFFFF;
            outline.enable = selected;
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
        outline = new h2d.filter.Outline(1, 0xFFFFFF, 1);
        outline.enable = false;
    }

    private override function init() {
        parentEntity.layers.filter = outline;
    }
}