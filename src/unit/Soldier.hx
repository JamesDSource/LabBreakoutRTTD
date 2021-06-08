package unit;

import hxd.Res;
import Selectable.Action;

enum SoldierState {
    Seek;
    Defend;
    Heal;
}

class Soldier extends Unit {
    private override function init() {
        super.init();

        var attackAction: Action = {
            name: "Attack",
            icon: Res.TexturePack.get("FightActionIcon"),
            callBack: attack,
            active: true
        }

        var defendAction: Action = {
            name: "Defend",
            icon: Res.TexturePack.get("DefenseActionIcon"),
            callBack: defend,
            active: true
        }

        var healAction: Action = {
            name: "Heal",
            icon: Res.TexturePack.get("HealActionIcon"),
            callBack: heal,
            active: true
        }

        selectable.actions = [attackAction, defendAction, healAction];
    }

    private function attack() {

    }

    private function defend() {

    }

    private function heal() {

    }
}