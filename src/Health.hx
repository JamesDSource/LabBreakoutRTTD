import h2d.Graphics;
import hcb.comp.Component;
import VectorMath;

class Health extends Component {
    public var maxHp(default, set): Float;
    public var hp: Float;
    private var hpChangeEventListeners: Array<(Float, Float) -> Void> = [];
    private var deathEventListeners: Array<() -> Void> = [];
    private var g: Graphics;
    public var gOffset: Vec2;
    public var hpBarLength: Float = 10;

    private function set_maxHp(maxHp: Float): Float {
        this.maxHp = maxHp;
        hp = Math.min(maxHp, hp);
        return maxHp;
    }

    public function new(name: String, maxHp: Float = 100) {
        super(name);
        this.maxHp = maxHp;
        hp = maxHp;
        
        g = new Graphics();
        g.alpha = 0.9;
        gOffset = vec2(0, -10);
        offsetHp(0);
    }

    private override function addedToRoom() {
        room.scene.add(g, 1);
    }

    private override function removedFromRoom() {
        g.remove();
    }

    private override function update() {
        var pos = parentEntity.getPosition();
        g.x = pos.x + gOffset.x;
        g.y = pos.y + gOffset.y;
    }

    public function offsetHp(offset: Float) {
        var prevHp = hp;
        
        hp += offset;
        hp = hxd.Math.clamp(hp, 0, maxHp);
        hpChangeEventCall(offset, hp);

        g.clear();
        g.beginFill(0xFF0000);
        g.drawRect(-hpBarLength/2, -2, hpBarLength*(hp/maxHp), 2);
        g.endFill();
        
        if(hp == 0 && prevHp != 0)
            deathEventCall();
    }

    // & hp change event
    public function hpChangeEventSubscribe(callBack: (Float, Float) -> Void) {
        hpChangeEventListeners.push(callBack);
    }

    public function hpChangeEventRemove(callBack: (Float, Float) -> Void): Bool {
        return hpChangeEventListeners.remove(callBack);
    }

    private function hpChangeEventCall(change: Float, hp: Float) {
        for(callBack in hpChangeEventListeners) {
            callBack(change, hp);
        }
    }

    // & death event
    public function deathEventSubscribe(callBack: () -> Void) {
        deathEventListeners.push(callBack);
    }

    public function deathEventRemove(callBack: () -> Void): Bool {
        return deathEventListeners.remove(callBack);
    }

    private function deathEventCall() {
        for(listener in deathEventListeners) {
            listener();
        }
    }
}