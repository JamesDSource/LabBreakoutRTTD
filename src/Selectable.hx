import hcb.comp.Component;

class Selectable extends Component {
    public var selected(default, set): Bool = false;

    private function set_selected(selected: Bool): Bool {
        if(selected != this.selected) {
            parentEntity.layers.filter = selected ? new h2d.filter.Outline(1, 0xFFFFFF, 1, false) : null;
            this.selected = selected;
        }
        return selected;
    }
}