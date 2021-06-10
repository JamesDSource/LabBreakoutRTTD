import hxd.Key;
import h2d.Scene.ScaleModeAlign;
import hcb.Room;
import VectorMath;

typedef MenuButton = {
    text: h2d.Text,
    callBack: () -> Void
}

class MainMenu extends Room {
    private var levels: Array<LdtkLevelData.LdtkLevelData_Level>;
    private var spacing: Float = 24;
    private var buttons: Array<MenuButton> = [];
    private var yStart: Float = 0;
    private var font: h2d.Font;
    private var index(default, set) = -1;

    private function set_index(index: Int): Int {
        if(buttons.length > 0) {
            if(this.index != -1 && this.index < buttons.length)
                buttons[this.index].text.color = new h3d.Vector(1.0, 1.0, 1.0);

            if(index != -1 && index < buttons.length)
                buttons[index].text.color = new h3d.Vector(1.0, 0.8, 0.5);
        }
        this.index = index;
        return index;
    }

    public function new(levels: Array<LdtkLevelData.LdtkLevelData_Level>) {
        super();
        this.levels = levels;
        font = hxd.res.DefaultFont.get();
    }
    
    public override function build() {
        scene.scaleMode = ScaleMode.LetterBox(Room.width, Room.height, false, Center, Center);
        generateMain();
    }

    private override function onUpdate() {
        var relY = scene.mouseY - yStart;
        index = Std.int(clamp(Std.int(relY/spacing), 0, buttons.length - 1));
        if(Key.isPressed(Key.MOUSE_LEFT)) {
            buttons[index].callBack();
        }
    }

    private function generateMain() {
        generateButtons(
            [
                {text: "Levels",    callBack: generateLevels},
                {text: "Quit",      callBack: () -> Sys.exit(0)}
            ]
        );
    }

    private function generateLevels() {
        var buttonData: Array<{text: String, callBack: () -> Void}> = [];

        for(level in levels) {
            buttonData.push({text: level.identifier, callBack: switchToLevel.bind(level)});
        }

        buttonData.push({text: "Back", callBack: generateMain});
        generateButtons(buttonData);
    }

    private function generateButtons(data: Array<{text: String, callBack: () -> Void}>) {
        clearButtons();
        var len: Int = data.length;
        var height: Float = len*spacing;
        yStart = Room.height/2 - height/2;
        
        var yPos: Float = yStart;
        for(buttonData in data) {
            var text: h2d.Text = new h2d.Text(font, scene);
            text.text = buttonData.text;
            text.textAlign = h2d.Text.Align.Center;
            text.x = std.Room.width/2;
            text.y = yPos;
            buttons.push({
                text: text,
                callBack: buttonData.callBack
            });
            yPos += spacing;
        }
    }

    private function clearButtons() {
        for(button in buttons) 
            button.text.remove();

        buttons = [];
    }

    private function switchToLevel(level: LdtkLevelData.LdtkLevelData_Level) {
        var newRoom = new std.Room(level);
        newRoom.build();
        project.room = newRoom;
    }
}