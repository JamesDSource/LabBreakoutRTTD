package enemy;

import hcb.comp.anim.*;
import hcb.math.Random;
import hcb.Entity;
import hcb.comp.Component;

class Enemy extends Component {
    private var movement: MoveableUnit;
    private var health: Health;
    private var animationPlayer: AnimationPlayer;
    private var setAnimation(default, set): Animation;

    private var metalWorth: Int = 10;
    private var roomExt: Room;

    private function set_setAnimation(setAnimation: Animation): Animation {
        if(this.setAnimation != setAnimation) {
            animationPlayer.setAnimationSlot("Main", setAnimation);
            this.setAnimation = setAnimation;
        }
        
        return setAnimation;
    }
    
    private override function init() {
        movement = cast parentEntity.getComponentOfType(MoveableUnit);
        health = cast parentEntity.getComponentOfType(Health);
        health.deathEventSubscribe(onDead);
        animationPlayer = cast parentEntity.getComponentOfType(AnimationPlayer);
        animationPlayer.addAnimationSlot("Main", 0);
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