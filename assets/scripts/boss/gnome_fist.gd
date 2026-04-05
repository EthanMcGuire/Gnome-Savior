extends Trap

enum FIST_STATE {
	IDLE,
	SLAM,
	SLAMMING,
	SLAM_RETURN,
	SLAP_START,
	SLAP,
	DO_SLAP,
	SLAPPING,
	RETURN
};

@export_group("Hand")
@export var isRightHand := false;

@export_group("Gore")
@export var bloodEffectCountMin := 24;
@export var bloodEffectCountMax := 32;
## Velocity angular range for the blood
@export var bloodEffectDegreesRange := 45.0;
## Velocity scale in relation to knockback the player received.
@export var bloodEffectVelocityScaleMin := 0.2;
@export var bloodEffectVelocityScaleMax := 0.35;
## Velocity scale in relation to knockback the player received.
@export var debrisVelocityScale := 0.5;
@export var debrisSizeMin := 48;
@export var debrisSizeMax := 64;

const HURT_TIME := 0.5;
const PLAYER_JUMP_KNOCKBACK := 650.0;
const FIST_DEATH_KNOCKBACK := 500.0;

const BASE_KNOCKBACK := 400.0;
const SLAP_KNOCKBACK := 1400.0;

# Idle
const HAND_BOB_AMOUNT := 6.0;
const HAND_BOB_TIME := 0.75;

var idleTween;

# Slam
const SLAM_START_Y_OFFSET := 64;
const SLAM_DELAY := 2;
const SLAM_RETURN_DELAY := 1.0;
const SLAM_SPEED := 525.0;
const HAND_LERP := 0.1;

# Slap
const SLAP_START_DELAY := 0.1;
const SLAP_DELAY := 1.0;
const SLAP_POS_OFFSET := 120;
const SLAP_SPEED := 600.0;
const SLAP_DISTANCE := 364.0;

var slapX;
var currentSlapDistance := 0.0;

# Return
# Delay before we can attack again
const RETURN_DELAY = 1.0;

var currentDelay := 0.0;

var hp = 6;
var hurt := 0.0;
var state = FIST_STATE.IDLE;
var fistStartX;
var fistStartY;

#region Public_Methods

func start() -> void:
	knockback = BASE_KNOCKBACK;
	
	fistStartX = global_position.x;
	fistStartY = global_position.y;
	
	if (isRightHand):
		slapX = fistStartX + SLAP_POS_OFFSET;
	else:
		slapX = fistStartX - SLAP_POS_OFFSET;
	
	_startState(FIST_STATE.IDLE);
	
func isBusy() -> bool:
	return state != FIST_STATE.IDLE;
	
func startSlam() -> void:
	_startState(FIST_STATE.SLAM);
	
func startSlap() -> void:
	_startState(FIST_STATE.SLAP_START);

#endregion Public_Methods

func _physics_process(delta: float) -> void:
	if (hurt > 0.0):
		hurt = max(hurt - delta, 0.0);
		
		if (hurt == 0.0):
			%SpriteFist.modulate = Color(1, 1, 1, 1);
	
	_stateControl(delta);
	_checkForDamage();
	
#region State
	
func _stateControl(delta: float) -> void:
	if (state == FIST_STATE.SLAM):
		global_position.x = lerpf(global_position.x, GameManager.getPlayerPosition().x, HAND_LERP);
		global_position.y = lerpf(global_position.y, fistStartY - SLAM_START_Y_OFFSET, HAND_LERP);
		
		currentDelay -= delta;
		
		if (currentDelay <= 0.0):
			_startState(FIST_STATE.SLAMMING);
			
	elif (state == FIST_STATE.SLAMMING):
		if (_slamToGround(delta)):
			_startState(FIST_STATE.SLAM_RETURN);
			
	elif (state == FIST_STATE.SLAM_RETURN):
		currentDelay -= delta;
		
		if (currentDelay <= 0.0):
			_startState(FIST_STATE.RETURN);
	elif (state == FIST_STATE.SLAP_START):
		global_position.y = lerpf(global_position.y, fistStartY - SLAM_START_Y_OFFSET, HAND_LERP * 2);
		
		currentDelay -= delta;
		
		if (currentDelay <= 0.0):
			_startState(FIST_STATE.SLAP);
			
	elif (state == FIST_STATE.SLAP):
		global_position.x = lerpf(global_position.x, slapX, HAND_LERP);
		
		if (_slamToGround(delta)):
			_startState(FIST_STATE.DO_SLAP);
	elif (state == FIST_STATE.DO_SLAP):
		currentDelay -= delta;
		
		if (currentDelay <= 0.0):
			_startState(FIST_STATE.SLAPPING);
	elif (state == FIST_STATE.SLAPPING):
		var moveAmount;
		
		moveAmount = min(SLAP_SPEED * delta, currentSlapDistance);
		currentSlapDistance -= moveAmount;
		
		if (isRightHand):
			global_position.x -= moveAmount;
		else:
			global_position.x += moveAmount;
			
		if (currentSlapDistance <= 0.0):
			knockback = BASE_KNOCKBACK;
			_startState(FIST_STATE.RETURN);
	elif (state == FIST_STATE.RETURN):
		currentDelay -= delta;
		
		if (currentDelay <= 0.0):
			_startState(FIST_STATE.IDLE);

func _slamToGround(delta: float) -> bool:
	global_position.y += delta * SLAM_SPEED;
		
	if (_isOnSolid()):
		%AudioStreamSlam.play();
		return true;
		
	return false;

func _startState(newState: FIST_STATE) -> void:
	state = newState;
	
	match (state):
		FIST_STATE.IDLE:
			_startIdleAnimation();
		FIST_STATE.SLAM:
			_stopIdleAnimation();
			currentDelay = SLAM_DELAY;
		FIST_STATE.SLAMMING:
			pass
		FIST_STATE.SLAM_RETURN:
			currentDelay = SLAM_RETURN_DELAY;
		FIST_STATE.SLAP_START:
			_stopIdleAnimation();
			currentDelay = SLAP_START_DELAY;
		FIST_STATE.SLAP:
			pass
		FIST_STATE.DO_SLAP:
			currentDelay = SLAP_DELAY;
		FIST_STATE.SLAPPING:
			currentSlapDistance = SLAP_DISTANCE;
			%AudioStreamSlap.play();
			knockback = SLAP_KNOCKBACK;
		FIST_STATE.RETURN:
			_startIdleAnimation();
			currentDelay = RETURN_DELAY;
	
func _startIdleAnimation() -> void:
	_stopIdleAnimation();
	
	idleTween = get_tree().create_tween().set_loops();
	idleTween.bind_node(self);
	idleTween.tween_property(self, "global_position", Vector2(fistStartX, fistStartY + HAND_BOB_AMOUNT), HAND_BOB_TIME).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD);
	idleTween.tween_property(self, "global_position", Vector2(fistStartX, fistStartY), HAND_BOB_TIME).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD);
	
func _stopIdleAnimation() -> void:
	if (idleTween):
		idleTween.kill();
	
#endregion State

func _isOnSolid() -> bool:
	var bodies = %AreaDamage.get_overlapping_bodies();
	
	for body in bodies:
		if (body is not PlayerController and body is not Gnome):
			return true;
			
	return false;

#region Damage
	
func _checkForDamage() -> void:
	if (hp <= 0): return;
	
	# Check for damage
	var bodies = %AreaHurt.get_overlapping_bodies();
	
	for body in bodies:
		if (body is PlayerController and body.velocity.y > 0.0):
			_takeDamage(body);

func _takeDamage(player) -> void:
	_knockbackPlayer(player);
	
	if (hurt > 0.0 || hp <= 0): return;
	
	hurt = HURT_TIME;
	%SpriteFist.modulate = Color(1, 0.5, 0.5, 1);
	
	get_parent().takeDamage();
	
	hp -= 1;
	
	if (hp <= 0):
		%AudioStreamDeath.play();
		
		var knockback;
	
		knockback = global_position - player.global_position;
		knockback = knockback.normalized() * FIST_DEATH_KNOCKBACK;
		
		%SpriteFist.visible = false;
		
		call_deferred("_createDeathEffects", knockback);		
	
### Knockback the player when they jump on us
func _knockbackPlayer(player) -> void:
	var knockbackDir: Vector2;
		
	knockbackDir = Vector2.UP;
	
	if (isRightHand):
		knockbackDir = knockbackDir.rotated(1);
		player.velocity.x -= PLAYER_JUMP_KNOCKBACK;
	else:
		knockbackDir = knockbackDir.rotated(-1);
		player.velocity.x += PLAYER_JUMP_KNOCKBACK;
	
	player.velocity += knockbackDir * PLAYER_JUMP_KNOCKBACK;
	
func _createDeathEffects(knockback: Vector2) -> void:
	GameManager.createBloodParticles(global_position);
	GameManager.createBloodEffect(global_position, knockback, bloodEffectDegreesRange, bloodEffectVelocityScaleMin, bloodEffectVelocityScaleMax, bloodEffectCountMin, bloodEffectCountMax);
	GameManager.createDebris(global_position + Vector2(-29.0, -32.0), %SpriteFist.get_texture(), %SpriteFist.flip_h, 0.1, knockback * debrisVelocityScale, Vector2(0.0, 0.0), Vector2(640.0, 577.0), debrisSizeMin, debrisSizeMax)
	
	%TimerFree.start();
	
#endregion Damage
	
#region Signals
	
func _on_area_damage_body_entered(body: Node2D) -> void:
	if (hp <= 0 || hurt > 0.0): return;
	
	if (body is PlayerController):
		_dealDamage(body, global_position);

func _on_timer_free_timeout() -> void:
	queue_free();

#endregion Signals
