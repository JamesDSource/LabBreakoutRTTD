import hcb.comp.Component;

class Health extends Component {
    public var maxHp(default, set): Float;
    public var hp: Float;
    private var hpChangeEventListeners: Array<(Float, Float) -> Void> = [];
    private var deathEventListeners: Array<() -> Void> = [];

    private function set_maxHp(maxHp: Float): Float {
        this.maxHp = maxHp;
        hp = Math.min(maxHp, hp);
        return maxHp;
    }

    public function new(name: String, maxHp: Float = 100) {
        super(name);
        this.maxHp = maxHp;
        hp = maxHp;
    }

    public function offsetHp(offset: Float) {
        var prevHp = hp;
        
        hp += offset;
        hp = hxd.Math.clamp(hp, 0, offset);
        hpChangeEventCall(offset, hp);
        
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