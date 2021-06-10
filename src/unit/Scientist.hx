package unit;

import Selectable.Action;
import hcb.math.Vector;
import hcb.Origin.OriginPoint;
import hxd.Res;
import hcb.comp.anim.Animation;

class Scientist extends Unit {
    private var idleAnimation: Animation;
    private var runAnimation: Animation;
    private var interactAnimation: Animation;

    private var currentResearch: Null<String> = null;

    private override function init() {
        super.init();

        WaveController.instance.waveTurnoverEventSubscribe(onWaveTurnover);

        body = Res.TexturePack.get("ScientistDead");

        var researchAction: Action = {
            name: "Research",
            icon: Res.TexturePack.get("ResearchActionIcon"),
            callBack: research,
            active:  true
        }

        var cancelAction: Action = {
            name: "Stop Researching",
            icon: Res.TexturePack.get("RemoveActionIcon"),
            callBack: () -> currentResearch = null,
            active:  true,
            activeCondition: () -> currentResearch != null,
            inactiveText: () -> "Not Researching"
        }

        selectable.actions = [researchAction, cancelAction];

        parentEntity.onMoveEventSubscribe(onMove);

        idleAnimation =     new Animation(Res.TexturePack.get("ScientistIdle"), 1, 0, OriginPoint.Center);
        runAnimation =      new Animation(Res.TexturePack.get("ScientistRun"), 4, 10, OriginPoint.Center);
        interactAnimation = new Animation(Res.TexturePack.get("ScientistInteract"), 4, 10, OriginPoint.Center);
        setAnimation = idleAnimation;
    }

    private override function update() {
        super.update();
        if(currentResearch == null)
            selectable.status = "Idling";
        else {
            var progress: Float = Research.getProgress(currentResearch);
            selectable.status = 'Researching: $currentResearch (${Std.int(progress*100)}%)';

            if(Research.isUnlocked(currentResearch))
                currentResearch = null;
        }
        animationStates();
    }

    private function animationStates() {
        if(movement.hasStopped()) {
            if(currentResearch == null)
                setAnimation = idleAnimation;
            else
                setAnimation = interactAnimation;
        }
        else
            setAnimation = runAnimation;
    }

    private function onMove(to: Vec2, from: Vec2) {
        var angle = hxd.Math.degToRad(Vector.getAngle(to - from));
        idleAnimation.rotation = angle;
        runAnimation.rotation = angle;
        interactAnimation.rotation = angle;
    }

    private function research() {
        ControlPanel.instance.queryResearch(
            (ab) -> {
                currentResearch = ab.action.name;
            }
        );
    }

    private function onWaveTurnover(?wave: Int) {
        if(currentResearch != null)
            Research.addProgress(currentResearch);
    }
}