package building;

import hcb.Origin.OriginPoint;
import hxd.Res;
import hcb.comp.Sprite;
import hcb.comp.Component;

class Teleporter extends Component {
    private var building: Building;
    private var base: Sprite;
    private var roomExt: Room;

    private override function init() {
        building = cast parentEntity.getComponentOfType(Building);

        base = new Sprite("Base", Res.TexturePack.get("Teleporter"), Center);
        parentEntity.addComponent(base);

        building.addDrawable(base.bitmap);
    }

    private override function update() {
        if(building.isDone()) {
            trace(roomExt);
            roomExt.gameOverMessage("Victory!\nYou Built The Teleporter And Escaped!");
        } 
    }

    private override function addedToRoom() {
        base.parentOverride = room.drawTo;
        roomExt = cast room;
    }

    private override function removedFromRoom() {
        parentEntity.removeComponent(base);
    }
}