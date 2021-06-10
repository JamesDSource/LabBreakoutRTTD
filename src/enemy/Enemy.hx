package enemy;

import hcb.math.Random;
import hcb.Entity;
import hcb.comp.Component;

class Enemy extends Component {
    private var movement: MoveableUnit;
    private var health: Health;
    private var metalWorth: Int = 10;
    private var roomExt: Room;
    
    private override function init() {
        movement = cast parentEntity.getComponentOfType(MoveableUnit);
        health = cast parentEntity.getComponentOfType(Health);
        health.deathEventSubscribe(onDead);
    }

    private override function addedToRoom() {
        roomExt = cast room;
    }

    private function onDead() {
        ControlPanel.instance.metals += metalWorth;
        parentEntity.remove();
    }

    private function getRandomUnit(): Entity {
        if(roomExt.units.length == 0)
            return null;
        Random.generator.shuffle(roomExt.units);
        return roomExt.units[0];
    }
}