extends Node2D
class_name EvilGnome

enum BOSS_STATE {
	STARTING,
	PHASE_1,
	PHASE_2,
	DEAD
};

const HURT_TIME := 0.5;
const ALPHA_CHANGE := 0.50;
const HEAD_BOB_AMOUNT := 8.0;
const HEAD_BOB_TIME := 0.75;

# Phase 1
const ATTACK_DELAY_MIN_PHASE_1 := 3;
const ATTACK_DELAY_MAX_PHASE_1 := 4;
const SLAM_CHANCE := 0.6;

# Phase 1
const ATTACK_DELAY_MIN_PHASE_2 := 1.5;
const ATTACK_DELAY_MAX_PHASE_2 := 3;

var currentAttackDelay: float;

var hp = 12;
var hurt := 0.0;

# State
var alpha = 0.0;
var bossStarted := false;
var state = BOSS_STATE.STARTING;

func startBoss() -> void:
	bossStarted = true;
	%FistLeft.start();
	%FistRight.start();
	_startState(BOSS_STATE.STARTING);

func takeDamage() -> void:
	if (hurt > 0.0): return;
	
	hurt = HURT_TIME;
	%AudioStreamHurt.play();
	%SpriteHurt.visible = true;
	%SpriteNormal.visible = false;
	
	hp -= 1;

	if (hp <= 0):
		_startState(BOSS_STATE.DEAD);
	elif (hp <= 6):
		_startState(BOSS_STATE.PHASE_2);

func _ready() -> void:
	modulate = Color(1, 1, 1, alpha);
	
	var headStartY = %Sprite.position.y;
	
	var tween = get_tree().create_tween().set_loops();
	tween.tween_property(%Sprite, "position:y", headStartY + HEAD_BOB_AMOUNT, HEAD_BOB_TIME).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD);
	tween.tween_property(%Sprite, "position:y", headStartY, HEAD_BOB_TIME).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD);
	
func _process(delta: float) -> void:
	if (!bossStarted): return;
	
	if (hurt > 0.0):
		hurt = max(hurt - delta, 0.0);
		
		if (hurt == 0.0):
			%SpriteHurt.visible = false;
			%SpriteNormal.visible = true;
			
	_stateControl(delta);
	
func _stateControl(delta: float) -> void:
	if (state == BOSS_STATE.STARTING):
		alpha = min(alpha + delta * ALPHA_CHANGE, 1.0);
		modulate = Color(1, 1, 1, alpha);
		
		if (alpha == 1.0):
			_startState(BOSS_STATE.PHASE_1);
	elif (state == BOSS_STATE.PHASE_1 || state == BOSS_STATE.PHASE_2):
		currentAttackDelay -= delta;
		
		if (currentAttackDelay <= 0):
			_startAttackDelay();
			
			if (randf() <= SLAM_CHANCE):
				_doSlam();
			else:
				_doSlap();
			

func _startState(newState: BOSS_STATE) -> void:
	state = newState;
	
	match (state):
		BOSS_STATE.STARTING:
			pass
		BOSS_STATE.PHASE_1:
			_startAttackDelay();
		BOSS_STATE.PHASE_2:
			_startAttackDelay();
		BOSS_STATE.DEAD:
			pass

func _startAttackDelay() -> void:
	if (state == BOSS_STATE.PHASE_1):
		currentAttackDelay = randf_range(ATTACK_DELAY_MIN_PHASE_1, ATTACK_DELAY_MAX_PHASE_1);
	else:
		currentAttackDelay = randf_range(ATTACK_DELAY_MIN_PHASE_2, ATTACK_DELAY_MAX_PHASE_2);

func _doSlam() -> void:
	if (!%FistLeft && !%FistRight): return;
	
	if (randf() <= 0.5):
		if (%FistLeft && !%FistLeft.isBusy()):
			%FistLeft.startSlam();
		elif (%FistRight && !%FistRight.isBusy()):
			%FistRight.startSlam();
	else:
		if (%FistRight && !%FistRight.isBusy()):
			%FistRight.startSlam();
		elif (%FistLeft && !%FistLeft.isBusy()):
			%FistLeft.startSlam();

func _doSlap() -> void:
	if (!%FistLeft && !%FistRight): return;
	
	if (randf() <= 0.5):
		if (%FistLeft && !%FistLeft.isBusy()):
			%FistLeft.startSlap();
		elif (%FistRight && !%FistRight.isBusy()):
			%FistRight.startSlap();
	else:
		if (%FistRight && !%FistRight.isBusy()):
			%FistRight.startSlap();
		elif (%FistLeft && !%FistLeft.isBusy()):
			%FistLeft.startSlap();
