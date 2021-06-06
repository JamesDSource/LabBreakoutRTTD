package building;

import hcb.comp.Component;

class Building extends Component {
    private var cost: Int = 0;
    private var placeable: Placeable;

    public function new(name: String, cost: Int) {
        super(name);
        this.cost = cost;
    }

    private override function init() {
        placeable = cast parentEntity.getComponentOfType(Placeable);
        placeable.placementCanceled = placementCanceled;
    }

    private function placementCanceled() {

    }
}