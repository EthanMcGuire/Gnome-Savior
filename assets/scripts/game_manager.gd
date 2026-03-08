extends Node

const STARTING_LEVEL := preload("res://assets/scenes/Levels/level_1.tscn");
const PLAYER_SCENE := preload("res://assets/scenes/Entities/player.tscn");
const SCENE_TRANSITION = preload("res://assets/scenes/Entities/scene_end_transition.tscn");
const SCENE_DEATH_TRANSITION = preload("res://assets/scenes/Entities/scene_death_transition.tscn");
const BLOOD_PARTICLE := preload("res://assets/scenes/Particles/blood_particles.tscn");
const STAR_PARTICLE := preload("res://assets/scenes/Particles/star_particles.tscn");
const BLOOD_EFFECT := preload("res://assets/scenes/Effects/blood.tscn");
const DEBRIS := preload("res://assets/scenes/Entities/debris.tscn");
const BLOOD_PARTICLE_SPRITE := preload("res://assets/sprites/Particles/particleblood_small.png");
const LEVEL_TRANSITION_TIME := 0.75;
const DEATH_TRANSITION_TIME := 0.5;
const COINS_ONE_UP := 100; 

var maxHp := 1;
var hp := maxHp;
var lives := 3;
var coins := 0;

var playerIsDead := false;
var levelLoaded := false;

# Base nodes
var hud: HUD;
var retryLabel: LabelRetry;
var pauseScreen: Control;
var speedrunTimer: SpeedrunTimer;
var players: Node2D;
var debris: Node2D;
var levelData: Node2D;
var particles: Node2D;
var effects: Node2D;
var musicPlayer: AudioStreamPlayer;
var soundLifeUp: AudioStreamPlayer;
var bloodSprite: Sprite2D;
var signText: SignText;
var projectiles: Node2D;

var player : PlayerController;
var camera: PlayerCamera = null;

# Blood
var bloodImage: Image;
var bloodTexture: Texture2D;
var bloodDrawImage = BLOOD_PARTICLE_SPRITE.get_image();
var bloodSize := 8;
var needToRedrawBlood := false;

# Level data
var level: Level = null;
var currentScene: PackedScene = null;
var currentLevelName: String = "";
var playerSpawn: PlayerSpawn = null;

# Speedrun time
var speedrunTimeMs := 0;

#region Save_Data_Variables

var heartContainersCollected = [];
var checkpointsCollected = [];
var currentCheckpoint = "";

#endregion Save_Data_Variables
 
func _ready() -> void:
	randomize();
	
	# So we can unpause the game
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
	bloodDrawImage.resize(bloodSize, bloodSize);
	
## This needs to be called to start the game! Should be called when in the scene 'level_base'
func startGame() -> void:
	_loadBaseNodes();
	_resetGameData();
	
	loadLevel(STARTING_LEVEL);
	
func _process(delta: float) -> void:
	_update(delta);

func _loadBaseNodes() -> void:
	hud = get_node("/root/LevelBase/CanvasLayer/HUD");
	assert(hud);
	retryLabel = get_node("/root/LevelBase/CanvasLayer/LabelRetry");
	assert(retryLabel);
	pauseScreen = get_node("/root/LevelBase/CanvasLayer/PauseScreen");
	assert(pauseScreen);
	speedrunTimer = get_node("/root/LevelBase/CanvasLayer/SpeedrunTimer");
	assert(speedrunTimer);
	players = get_node("/root/LevelBase/Players");
	assert(players);
	debris = get_node("/root/LevelBase/Debris");
	assert(debris);
	levelData = get_node("/root/LevelBase/LevelData");
	assert(levelData);
	particles = get_node("/root/LevelBase/Particles");
	assert(particles);
	effects = get_node("/root/LevelBase/Effects");
	assert(effects);
	musicPlayer = get_node("/root/LevelBase/Audio/MusicPlayer");
	assert(musicPlayer);
	soundLifeUp = get_node("/root/LevelBase/Audio/AudioStreamLifeUp");
	assert(soundLifeUp);
	bloodSprite = get_node("/root/LevelBase/Blood");
	assert(bloodSprite);
	signText = get_node("/root/LevelBase/CanvasBack/SignText");
	assert(signText);
	projectiles = get_node("/root/LevelBase/Projectiles");
	assert(projectiles);

func _resetGameData() -> void:
	setLives(3);
	setCoins(0);
	hp = maxHp;
	setPlayerMaxHp(maxHp);

func gameOver() -> void:
	get_tree().quit();
	
func _toggleGamePaused() -> void:
	get_tree().paused = !get_tree().paused;
	pauseScreen.visible = get_tree().paused;

#region Update

func _update(delta: float) -> void:
	if (needToRedrawBlood):
		needToRedrawBlood = false;
		_updateBloodSprite();
	
	if (levelLoaded):
		_updateLevel(delta);

func _updateLevel(delta: float) -> void:
	if (Input.is_action_just_pressed("pause")):
		_toggleGamePaused();
		
	if (!get_tree().paused):
		_updateSpeedrunTime(delta);
		
		if (Input.is_action_just_pressed("restart")):
			print("RESTARTING LEVEL.");
			
			if (playerIsDead):
				playerIsDead = false;
				retryLabel.visible = false;
				startDeathTransition(currentScene);
			else:
				# Don't reduce lives
				startLevelTransition(currentScene);

func _updateSpeedrunTime(delta: float) -> void:
	speedrunTimeMs += delta * 1000;
	speedrunTimer.setTime(speedrunTimeMs);

#endregion Update
		
#region Level
	
func loadLevel(nextScene: PackedScene) -> void:
	assert(nextScene);
	
	currentScene = nextScene;
	
	_destroyPlayer();
	_createPlayer();
	_unloadLevelData();
	
	# Load the level
	level = currentScene.instantiate();
	levelData.add_child(level);
	
	# Player
	playerSpawn = level.get_node("PlayerSpawn");
	assert(playerSpawn);
	
	# New level was loaded?
	if (currentLevelName != level.levelName):
		_loadNewLevelData();
		
	# Only move the player to spawn if we don't have a checkpoint set
	if (currentCheckpoint == ""):
		movePlayerToSpawn();
		
	levelLoaded = true;

func _unloadLevelData() -> void:
	for child in levelData.get_children():
		child.free();
	
	_clearDebris();
	_freeParticles();
	_freeEffects();
	_freeProjectiles();
	playerSpawn = null;

func _loadNewLevelData() -> void:
	currentLevelName = level.levelName;
	_createBloodCanvas(level.levelWidth, level.levelHeight);
	_clearCheckpointData();
	_stopMusic();
	_playMusic(level.music);

func startLevelTransition(nextScene: PackedScene) -> void:
	var transition;
	
	levelLoaded = false;
	
	transition = SCENE_TRANSITION.instantiate();
	add_child(transition);
	transition.startTransition(LEVEL_TRANSITION_TIME, nextScene);
	
func startDeathTransition(nextScene: PackedScene) -> void:
	var transition;
	
	levelLoaded = false;
	
	transition = SCENE_DEATH_TRANSITION.instantiate();
	add_child(transition);
	transition.startTransition(DEATH_TRANSITION_TIME, nextScene);

#endregion Level

#region Music

func _playMusic(music: AudioStream):
	if (!music):
		print("GameManager: In _playMusic() music is null.");
		return;
		
	musicPlayer.stream = music;
	musicPlayer.play();

func _stopMusic():
	musicPlayer.stop();

#endregion Music

#region Blood

func _createBloodCanvas(width: int, height: int):
	bloodImage = Image.create(width, height, false, Image.FORMAT_RGBA8);
	bloodTexture = ImageTexture.create_from_image(bloodImage);
	bloodSprite.set_texture(bloodTexture);
	_clearBloodCanvas();

func _clearBloodCanvas():
	assert(bloodImage);
	bloodImage.fill(Color(0.0, 0.0, 0.0, 0.0));
	
	needToRedrawBlood = true;

func _updateBloodSprite():
	assert(bloodImage);
	assert(bloodTexture);
	
	bloodTexture.update(bloodImage);

func drawBlood(pos: Vector2):
	assert(bloodImage);
	#print("Drawing blood at " + str(pos));
	
	bloodImage.blit_rect(bloodDrawImage, Rect2(0.0, 0.0, bloodSize, bloodSize), pos - Vector2(bloodSize / 2.0, bloodSize / 2.0));
	
	needToRedrawBlood = true;

#endregion Blood

#region Particles

func createBloodParticles(pos: Vector2) -> void:
	var part = BLOOD_PARTICLE.instantiate();
	part.global_position = pos;
	addParticles(part);
	
func createStarParticles(pos: Vector2) -> void:
	var part = STAR_PARTICLE.instantiate();
	part.global_position = pos;
	addParticles(part);

func addParticles(particleNode) -> void:
	particles.add_child(particleNode);

func _freeParticles() -> void:
	for child in particles.get_children():
		child.queue_free();

#endregion Particles

#region Gnomes

func addGnome(gnomeNode) -> void:
	assert(level);
	level.addGnome(gnomeNode);

#endregion Gnomes

#region Effects

func createBloodEffect(pos: Vector2, knockback: Vector2, degreesRange: float, velocityScaleMin: float, velocityScaleMax: float, countMin: int, countMax: int) -> void:
	var count;

	count = randi_range(countMin, countMax);
	
	while (count > 0):
		var blood = BLOOD_EFFECT.instantiate();
		var bloodVelocity;
		var velocityScale;
		
		velocityScale = randf_range(velocityScaleMin, velocityScaleMax);
		bloodVelocity = velocityScale * knockback.rotated(
			rad_to_deg(randf_range(-degreesRange, degreesRange)));
		
		blood.global_position = pos;
		blood.setVelocity(bloodVelocity);
		
		addEffect(blood);
		
		count -= 1;

func addEffect(effectNode) -> void:
	effects.add_child(effectNode);

func _freeEffects() -> void:
	for child in effects.get_children():
		child.queue_free();

#endregion Effects

#region Projectiles

func addProjectile(projectileNode) -> void:
	projectiles.add_child(projectileNode);
	
func _freeProjectiles() -> void:
	for child in projectiles.get_children():
		child.queue_free();

#endregion Projectiles

#region Sign

func showSign(text: String) -> void:
	signText.setText(text);
	signText.showSign();

func hideSign() -> void:
	signText.hideSign();

#endregion Sign

#region Player

func _createPlayer() -> void:
	player = PLAYER_SCENE.instantiate();
	assert(player);
	players.add_child(player);
	
	camera = player.get_node("PlayerCamera");
	assert(camera);

func _destroyPlayer() -> void:
	if (player == null):
		return;
		
	camera.queue_free();
	player.queue_free();
	player.remove_child(camera);
	players.remove_child(player);
	camera = null;
	player = null;
	
func movePlayerToSpawn() -> void:
	if (!playerSpawn):
		print("GameManager: Called movePlayerToSpawn without a player spawn set!");
		
	assert(playerSpawn);
	
	if (playerSpawn):
		setPlayerPosition(playerSpawn.global_position);
		
func setPlayerPosition(newPosition: Vector2) -> void:
	assert(player);
	
	player.global_position = newPosition;
	moveCameraToGoal();
	
func getPlayerPosition() -> Vector2:
	assert(player);
	
	return player.global_position;
		
#endregion Player

#region Camera

func setCameraLimits(left: int, top: int, right: int, bottom: int):
	assert(camera);
	camera.setLimits(left, top, right, bottom);

func moveCameraToGoal():
	assert(camera);
	camera.reset_smoothing();

#endregion Camera

#region Debris

func createDebris(pos: Vector2, texture: Texture2D, flipH: bool, knockback: Vector2, spriteOffset: Vector2, spriteSize: Vector2, debrisSizeMin: float, debrisSizeMax: float):
	var x;
	var y;
	
	x = 0.0;
	y = 0.0;
	
	while x < spriteSize.x:
		var debrisWidth;
		
		debrisWidth = randi_range(debrisSizeMin, debrisSizeMax);
		debrisWidth = min(debrisWidth, spriteSize.x - x);
		
		while y < spriteSize.y:
			var debrisHeight;
			var debris: Debris = DEBRIS.instantiate();
			
			debrisHeight = randi_range(debrisSizeMin, debrisSizeMax);
			debrisHeight = min(debrisHeight, spriteSize.y - y);

			debris.global_position = Vector2(pos.x + x, pos.y + y);
			debris.setTexture(texture, flipH);
			debris.setRegion(spriteOffset.x + x, spriteOffset.y + y, debrisWidth, debrisHeight);
			debris.applyKnockback(knockback);
			
			GameManager.addDebris(debris);
			
			y += debrisHeight;
		
		x += debrisWidth;
		y = 0.0;

func addDebris(_debris) -> void:
	debris.add_child(_debris);

func _clearDebris() -> void:
	for child in debris.get_children():
		child.queue_free();
		
#endregion Debris

#region Coins

func getCoins() -> int:
	return coins;
	
func addCoins(amount: int):
	setCoins(coins + amount);

func setCoins(amount: int):
	coins = amount;
	
	# Add one ups
	if (coins >= COINS_ONE_UP):
		addLives(coins / COINS_ONE_UP);
		coins = coins % COINS_ONE_UP;
	
	hud.updateCoins(coins);

#endregion Coins

#region Lives

func getLives() -> int:
	return lives;
	
func addLives(amount: int):
	setLives(lives + amount);
	
	if (amount > 0):
		soundLifeUp.play();

func setLives(amount: int):
	lives = amount;
	hud.updateLives(lives);

#endregion Lives

#region Health

func increasePlayerMaxHealth(amount: int) -> void:
	setPlayerMaxHp(maxHp + amount);
	setPlayerHp(hp + amount);

func getPlayerMaxHp() -> int:
	return maxHp;
	
func getPlayerHp() -> int:
	return hp;

func setPlayerMaxHp(amount: int):
	maxHp = amount;
	hud.updateMaxHealth(maxHp);
	setPlayerHp(hp);

func setPlayerHp(amount: int):
	hp = clamp(amount, 0, maxHp);
	hud.updateHealth(hp);

## Adds HP to the player. [br]
## [param amount]: Amount of HP to add. Should be a positive integer.
func addPlayerHp(amount: int) -> void:
	setPlayerHp(hp + abs(amount));
	
## Removes HP from the player. [br]
## [param amount]: Amount of HP to remove. Should be a positive integer.
func removePlayerHp(amount: int) -> void:
	setPlayerHp(hp - abs(amount));
	
	# Game over
	if (hp == 0):
		playerIsDead = true;
		retryLabel.visible = true;

#endregion Health

#region Save_Data

func checkHeartContainerCollected(name: String) -> bool:
	if (name in heartContainersCollected):
		return true;
		
	return false;

func _addCollectedHeartContainer(name: String) -> void:
	heartContainersCollected.push_back(name);

func checkCheckpointCollected(name: String) -> bool:
	if (name in checkpointsCollected):
		return true;
		
	return false;

func getCurrentCheckpointName() -> String:
	return currentCheckpoint;

func _addCollectedCheckpoint(name: String) -> void:
	checkpointsCollected.push_back(name);
	
func _setCurrentCheckpoint(checkpointName: String) -> void:
	currentCheckpoint = checkpointName;
	
func _clearCheckpointData() -> void:
	currentCheckpoint = "";
	checkpointsCollected = [];

#endregion Save_Data

#region Game_Events

func heartContainerCollected(name: String) -> void:
	print("Player collected heart container: " + name + ".");
	increasePlayerMaxHealth(1);
	_addCollectedHeartContainer(name);

func checkpointHit(name: String) -> void:
	print("Player hit checkpoint: " + name + ".");
	_setCurrentCheckpoint(name);
	_addCollectedCheckpoint(name);

#endregion Game_Events
