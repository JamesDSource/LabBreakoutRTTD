package unit;

import hcb.comp.anim.Animation;
import hcb.comp.anim.AnimationPlayer;
import hcb.comp.Component;

class Unit extends Component {
    private var selectable: Selectable;
    private var roomExt: Room;
    private var unitController: UnitController;
    private var movement: MoveableUnit;
    private var animationPlayer: AnimationPlayer;
    private var setAnimation(default, set): Animation;

    private function set_setAnimation(setAnimation: Animation): Animation {
        if(this.setAnimation != setAnimation) {
            this.setAnimation = setAnimation;
            animationPlayer.setAnimationSlot("Main", setAnimation);            
        }

        return setAnimation;
    }

    private override function init() {
        selectable = cast parentEntity.getComponentOfType(Selectable);
        movement = cast parentEntity.getComponentOfType(MoveableUnit);
        animationPlayer = cast parentEntity.getComponentOfType(AnimationPlayer);
        animationPlayer.addAnimationSlot("Main", 0);
    }

    private override function addedToRoom() {
        roomExt = cast room;
        unitController = cast roomExt.playerController.getComponentOfType(UnitController);
    }
}