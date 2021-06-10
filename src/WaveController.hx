import hcb.Entity;
import hcb.math.Random;
import hcb.Timer;
import hcb.comp.Component;
import VectorMath;

typedef WaveEnemy = {
    prefab: () -> Array<Component>,
    probability: Int,
    cost: Int,
    minRound: Int
}

class WaveController {
    public static final enemies: Array<WaveEnemy> = [
        {
            prefab: Prefabs.generateWolf,
            probability: 10,
            cost: 1,
            minRound: 1
        }
    ];

    public static var instance: WaveController = null;

    public var wave(default, null): Int = 0;
    private var room: Room;
    private var waveTimer: Timer;
    private var spawnTimer: Timer;
    private var spawnPositions: Array<Vec2> = [];
    
    private var tokens: Int = 0;
    private var enemyCount: Int = 0;
    private var maxEnemies: Int = 15;

    public static function startWaves(room: Room, spawnPositions: Array<Vec2>) {
        instance = new WaveController(room, spawnPositions);
    }

    private function new(room: Room, spawnPositions: Array<Vec2>) {
        this.room = room;
        waveTimer = new Timer("Wave", 2, nextWave);
        spawnTimer = new Timer("Spawn", 2, spawn);
        room.addTimer(waveTimer);
        room.addTimer(spawnTimer);
        this.spawnPositions = spawnPositions.copy();
    }

    public function nextWave(?t: String) {
        wave++;
        tokens = 10 + wave*2;
        maxEnemies = Std.int(Math.min(maxEnemies + 1, 50));
        spawnTimer.initialTime = Math.max(spawnTimer.initialTime - 0.1, 0.2);
    }

    public function spawn(?t: String) {
        spawnTimer.reset();
        if(enemyCount < maxEnemies) {
            var possibleEnemies: Array<WaveEnemy> = [];
            for(enemy in enemies) {
                if(wave < enemy.minRound || tokens < enemy.cost)
                    continue;

                for(i in 0...enemy.probability) {
                    possibleEnemies.push(enemy);
                }
            }
            Random.generator.shuffle(possibleEnemies);

            if(possibleEnemies.length > 0) {
                var enemy = possibleEnemies[0];
                Random.generator.shuffle(spawnPositions);
                var enemyEnt = new Entity(enemy.prefab(), spawnPositions[0], 1);
                room.addEntity(enemyEnt);

                var health: Health = cast enemyEnt.getComponentOfType(Health);
                if(health != null)
                    health.deathEventSubscribe(() -> enemyCount--);
                
                tokens -= enemy.cost;
                enemyCount++;
            }
            else if(enemyCount == 0) {
                tokens = 0;
                if(waveTimer.timeRemaining == 0)
                    waveTimer.reset();
            }
        }
    }

    public function getTimeLeft(): Float {
        return waveTimer.timeRemaining;
    }
}