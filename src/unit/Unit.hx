package unit;

import hxd.Res;
import hcb.Entity;
import hcb.comp.anim.Animation;
import hcb.comp.anim.AnimationPlayer;
import hcb.comp.Component;

class Unit extends Component {
    private var selectable: Selectable;
    private var roomExt: Room;
    
    private var unitController: UnitController;
    private var movement: MoveableUnit;
    private var animationPlayer: AnimationPlayer;
    private var health: Health;

    private var passiveHpRegen: Float = 0.01;

    private var setAnimation(default, set): Animation;

    public var body: h2d.Tile = null;

    private var deathSound: hxd.res.Sound;

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
        health = cast parentEntity.getComponentOfType(Health);
        health.deathEventSubscribe(dead);

        deathSound = Res.Sounds.UnitDeath;
    }

    private override function update() {
        if(Research.isUnlocked(Research.unitHpRegenUpgrade) && health.hp < health.maxHp) {
            health.offsetHp(passiveHpRegen);
        }
    }

    private override function addedToRoom() {
        roomExt = cast room;
        unitController = cast roomExt.playerController.getComponentOfType(UnitController);
    }

    private function dead() {
        deathSound.play();
        var body = new Entity(Prefabs.generateBody(body), parentEntity.getPosition(), 0);
        room.addEntity(body);
        parentEntity.remove();
    }
}