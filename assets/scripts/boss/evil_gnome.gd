extends Node2D
class_name EvilGnome

@export var raisingDoor: RaisingDoor;

enum BOSS_STATE {
	STARTING,
	PHASE_1,
	PHASE_2,
	PHASE_3,
	DEAD
};

const NOOSE_GNOME := preload("res://assets/scenes/Entities/boss/noose_gnome.tscn");
const MISSILE_GNOME := preload("res://assets/scenes/Entities/boss/missile_gnome.tscn");

const PHASE_3_HP := 6;
const PHASE_2_HP := 9;

const HURT_TIME := 0.5;
const ALPHA_CHANGE := 0.75;
const HEAD_BOB_AMOUNT := 8.0;
const HEAD_BOB_TIME := 0.75;
const HEAD_ROTATION_LERP := 0.1;

const ATTACK_DELAY_START_FIGHT := 0.25;
const SLAM_CHANCE := 0.5;

# Phase 1
const ATTACK_DELAY_MIN_PHASE_1 := 3;
const ATTACK_DELAY_MAX_PHASE_1 := 4;

# Phase 2
const ATTACK_DELAY_MIN_PHASE_2 := 1.5;
const ATTACK_DELAY_MAX_PHASE_2 := 3;
const NOOSE_DELAY_MIN := 2;
const NOOSE_DELAY_MAX := 5;

# Phase 3
const MISSILE_DELAY_MIN := 3;
const MISSILE_DELAY_MAX := 5;
const MISSILE_START_DELAY := 1;
const MISSILE_SHOOT_TIME := 1;
const MISSILE_LAUNCH_DELAY := 0.15;

var currentAttackDelay: float;
var currentNooseDelay: float;
var currentMissileDelay: float;
var currentMissileStartDelay: float;
var currentMissileShootTime: float;
var currentMissileLaunchDelay: float;
var launchingMissile := false;

@onready var leftFist = %FistLeft;
@onready var rightFist = %FistRight;

var hp = 12;
var hurt := 0.0;

# State
var alpha = 0.0;
var bossStarted := false;
var state = BOSS_STATE.STARTING;

func startBoss() -> void:
	bossStarted = true;
	leftFist.start();
	rightFist.start();
	_startState(BOSS_STATE.STARTING);

func takeDamage() -> void:
	if (state == BOSS_STATE.STARTING || state == BOSS_STATE.DEAD): return;
	
	hurt = HURT_TIME;
	%AudioStreamHurt.play();
	%SpriteHurt.visible = true;
	%SpriteNormal.visible = false;
	%SpriteShoot.visible = false;
	
	hp -= 1;

	if (hp <= 0):
		_startState(BOSS_STATE.DEAD);
	elif (state == BOSS_STATE.PHASE_2 && hp <= PHASE_3_HP):
		_startState(BOSS_STATE.PHASE_3);
	elif (state == BOSS_STATE.PHASE_1 && hp <= PHASE_2_HP):
		_startState(BOSS_STATE.PHASE_2);

func _ready() -> void:
	modulate = Color(1, 1, 1, alpha);
	
	var headStartY = %Head.position.y;
	
	var tween = get_tree().create_tween().set_loops();
	tween.bind_node(self);
	tween.tween_property(%Head, "position:y", headStartY + HEAD_BOB_AMOUNT, HEAD_BOB_TIME).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD);
	tween.tween_property(%Head, "position:y", headStartY, HEAD_BOB_TIME).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD);
	
func _process(delta: float) -> void:
	if (!bossStarted): return;
	
	if (hurt > 0.0):
		hurt = max(hurt - delta, 0.0);
		
		if (hurt == 0.0):
			%SpriteHurt.visible = false;
			
			if (!launchingMissile):
				%SpriteNormal.visible = true;
			else:
				%SpriteShoot.visible = true;
			
	_stateControl(delta);
		
func _startState(newState: BOSS_STATE) -> void:
	state = newState;
	
	match (state):
		BOSS_STATE.STARTING:
			pass
		BOSS_STATE.PHASE_1:
			# Make first attack happen quickly
			currentAttackDelay = ATTACK_DELAY_START_FIGHT;
		BOSS_STATE.PHASE_2:
			_startAttackDelay();
			_startNooseDelay();
		BOSS_STATE.PHASE_3:
			launchingMissile = false;
			
			_startAttackDelay();
			_startNooseDelay();
			_startMissileDelay();
		BOSS_STATE.DEAD:
			%AudioStreamDead.play();
			%AudioStreamHurt.stop();
			%DestroyTimer.start();
			
			# Raise the exit door
			raisingDoor.raise();
	
func _startAttackDelay() -> void:
	if (state == BOSS_STATE.PHASE_1):
		currentAttackDelay = randf_range(ATTACK_DELAY_MIN_PHASE_1, ATTACK_DELAY_MAX_PHASE_1);
	else:
		currentAttackDelay = randf_range(ATTACK_DELAY_MIN_PHASE_2, ATTACK_DELAY_MAX_PHASE_2);

func _startNooseDelay() -> void:
		currentNooseDelay = randf_range(NOOSE_DELAY_MIN, NOOSE_DELAY_MAX);
		
func _startMissileDelay() -> void:
		currentMissileDelay = randf_range(MISSILE_DELAY_MIN, MISSILE_DELAY_MAX);
	
func _stateControl(delta: float) -> void:
	if (state == BOSS_STATE.STARTING):
		alpha = min(alpha + delta * ALPHA_CHANGE, 1.0);
		modulate = Color(1, 1, 1, alpha);
		
		if (alpha == 1.0):
			_startState(BOSS_STATE.PHASE_1);
	elif (state == BOSS_STATE.PHASE_1):
		_checkForAttack(delta);
	elif (state == BOSS_STATE.PHASE_2):
		_checkForAttack(delta);
		_checkForNoose(delta);
	elif (state == BOSS_STATE.PHASE_3):
		_checkForAttack(delta);
		_checkForNoose(delta);
		_checkForMissile(delta);
	elif (state == BOSS_STATE.DEAD):
		alpha = max(alpha - delta * ALPHA_CHANGE, 0.0);
		modulate = Color(1, 1, 1, alpha);
			
func _checkForAttack(delta: float) -> void:
	currentAttackDelay -= delta;
		
	if (currentAttackDelay <= 0):
		_startAttackDelay();
		
		if (randf() <= SLAM_CHANCE):
			_doSlam();
		else:
			_doSlap();
			
func _checkForNoose(delta: float) -> void:
	currentNooseDelay -= delta;
		
	if (currentNooseDelay <= 0):
		_startNooseDelay();
		_doNoose();

func _checkForMissile(delta: float) -> void:
	if (!launchingMissile):
		_resetFaceDirection(delta);
		
		currentMissileDelay -= delta;
			
		if (currentMissileDelay <= 0):
			launchingMissile = true;
			currentMissileStartDelay = MISSILE_START_DELAY;
			currentMissileShootTime = MISSILE_SHOOT_TIME;
			currentMissileLaunchDelay = MISSILE_LAUNCH_DELAY;
			
			if (hurt == 0.0):
				%SpriteNormal.visible = false;
				%SpriteShoot.visible = true;
	else:
		_facePlayer(delta);
		
		if (currentMissileStartDelay > 0):
			currentMissileStartDelay -= delta;
		else:
			# Repeatedly shoot missiles until shoot time is complete
			currentMissileShootTime -= delta;
			currentMissileLaunchDelay -= delta;
			
			if (currentMissileShootTime <= 0):
				launchingMissile = false;
				_startMissileDelay();
				
				if (hurt == 0.0):
					%SpriteNormal.visible = true;
					%SpriteShoot.visible = false;
			if (currentMissileLaunchDelay <= 0):
				currentMissileLaunchDelay = MISSILE_LAUNCH_DELAY;
				_doMissile();
	
func _resetFaceDirection(delta: float) -> void:
	_setHeadRotation(lerp_angle(%Head.rotation, 0, HEAD_ROTATION_LERP));

func _facePlayer(delta: float) -> void:
	var dir;
	
	dir = GameManager.getPlayerPosition() - global_position;
	dir = dir.normalized();
	
	_setHeadRotation(lerp_angle(%Head.rotation, dir.angle(), HEAD_ROTATION_LERP));

func _setHeadRotation(newRotation: float) -> void:
	%Head.rotation = newRotation;
	
	if (%Head.rotation_degrees >= 90.0):
		%SpriteNormal.flip_v = true;
		%SpriteHurt.flip_v = true;
		%SpriteShoot.flip_v = true;
	else:
		%SpriteNormal.flip_v = false;
		%SpriteHurt.flip_v = false;
		%SpriteShoot.flip_v = false;

#region Attacks

func _doSlam() -> void:
	if (!leftFist && !rightFist): return;
	
	if (randf() <= 0.5):
		if (leftFist && !leftFist.isBusy()):
			leftFist.startSlam();
		elif (rightFist && !rightFist.isBusy()):
			rightFist.startSlam();
	else:
		if (rightFist && !rightFist.isBusy()):
			rightFist.startSlam();
		elif (leftFist && !leftFist.isBusy()):
			leftFist.startSlam();

func _doSlap() -> void:
	if (!leftFist && !rightFist): return;
	
	if (randf() <= 0.5):
		if (leftFist && !leftFist.isBusy()):
			leftFist.startSlap();
		elif (rightFist && !rightFist.isBusy()):
			rightFist.startSlap();
	else:
		if (rightFist && !rightFist.isBusy()):
			rightFist.startSlap();
		elif (leftFist && !leftFist.isBusy()):
			leftFist.startSlap();

func _doNoose() -> void:
	var gnome;
	var spawnX;
	var spawnY;
	
	spawnX = randi_range(GameManager.getCameraLimitLeft() + 32, GameManager.getCameraLimitRight() - 32);
	spawnY = GameManager.getCameraLimitTop() - 32;
	
	gnome = NOOSE_GNOME.instantiate();
	gnome.global_position = Vector2(spawnX, spawnY);
	
	get_parent().add_child(gnome);
	
func _doMissile() -> void:
	var gnome;
	var spawnPos;
	var spawnXOffset;
	var spawnYOffset;
	var dir;
	
	spawnPos = %Head.global_position;
	
	spawnXOffset = 0.0;
	spawnYOffset = 16.0;
	
	if (%SpriteNormal.flip_v):
		spawnYOffset *= -1.0;
	
	spawnPos += Vector2(spawnXOffset, spawnYOffset).rotated(%Head.rotation);
	
	dir = GameManager.getPlayerPosition() - spawnPos;
	dir = dir.normalized();
	
	gnome = MISSILE_GNOME.instantiate();
	gnome.global_position = spawnPos;
	gnome.rotation = dir.angle();
	
	get_parent().add_child(gnome);
	
#endregion Attacks

func _on_destroy_timer_timeout() -> void:
	queue_free();
