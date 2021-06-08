package enemy;

import hcb.comp.Component;

class Enemy extends Component {
    private var movement: MoveableUnit;
    private var health: Health;
    private var metalWorth: Int = 10;
    
    private override function init() {
        movement = cast parentEntity.getComponentOfType(MoveableUnit);
        health = cast parentEntity.getComponentOfType(Health);
        health.deathEventSubscribe(onDead);
    }

    private function onDead() {
        ControlPanel.instance.metals += metalWorth;
        parentEntity.remove();
    }
}