package building;

import hcb.comp.Component;

class Building extends Component {
    private var cost: Int = 0;
    private var placeable: Placeable;

    private var shader: shader.BuildingShader;
    private var drawables: Array<h2d.Drawable> = [];

    private var progress: Float = 0;
    private var done: Bool = false;

    public static final blue = new hxsl.Types.Vec(0.1, 0.1, 0.9);
    public static final red = new hxsl.Types.Vec(0.9, 0.1, 0.1);

    public function new(name: String, cost: Int) {
        super(name);
        this.cost = cost;
        shader = new shader.BuildingShader();
    }

    private override function init() {
        placeable = cast parentEntity.getComponentOfType(Placeable);
        placeable.placementCanceled = placementCanceled;
    }

    private function placementCanceled() {
        ControlPanel.instance.metals += cost;
    }

    private override function update() {
        if(!placeable.isPlaced())
            shader.color = placeable.canBePlaced() ? blue : red;
    }

    public function addDrawable(d: h2d.Drawable) {
        if(!done)
            d.addShader(shader);
        drawables.push(d);
    }

    public function removeDrawable(d: h2d.Drawable): Bool {
        d.removeShader(shader);
        return drawables.remove(d);
    }

    public function addProgress(amount: Float) {
        if(done)
            return;
        
        progress += amount;
        if(progress >= 1) {
            done = true;
            progress = 1;

            for(drawable in drawables)
                drawable.removeShader(shader);
        }
    }

    public function isDone(): Bool {
        return done;
    }
}