extends CharacterBody2D
class_name PlayerController

enum PLAYER_STATE {
	GROUNDED,
	JUMPING,
	FALLING,
	HURT,
	DEAD,
	GUARD_GROUND,
	GUARD_AIR
};

enum PLAYER_ANIMATION {
	IDLE,
	WALK,
	JUMP,
	FALL,
	GUARD
};

const ANIMATION_NAMES = {
	PLAYER_ANIMATION.IDLE: "idle",
	PLAYER_ANIMATION.WALK: "walk",
	PLAYER_ANIMATION.JUMP: "jump",
	PLAYER_ANIMATION.FALL: "fall",
	PLAYER_ANIMATION.GUARD: "guard"
}

#region Export_Variables

@export_group("Physics")
@export var maxSpeed = 136.0;
@export var moveVelocity = 600.0;
@export var stopVelocity = 900.0;
@export var turnAroundVelocity := 950.0;
@export var speedStopLerp = 32.0;
@export var jumpVelocity = -300.0;

@export_group("Royal_Guard")
@export var royalGuardTime := 0.2;
@export var royalGuardCooldown := 0.25;
@export var royalGuardInvincibilityTime := 0.25;
@export var royalGuardKnockbackScale := 1.25;
@export var royalGuardHorizontalVelocityScale := 0.75;

@export_group("Sound")
@export var baseSoundJumpVolume := 1.0;
### Volume to go towards when stopping the jump sound
@export var jumpSoundStopDb := -35.0;
### Stop duration in seconds
@export var jumpSoundStopTime := 2.0;
@export var baseSoundScreamVolume := 1.0;
@export var soundScreamVolumeLoud := 15.0;
@export var soundScreamLoudChance := 0.33;

@export_group("Gore")
@export var bloodEffectCountMin := 16;
@export var bloodEffectCountMax := 24;
## Velocity angular range for the blood
@export var bloodEffectDegreesRange := 45.0;
## Velocity scale in relation to knockback the player received.
@export var bloodEffectVelocityScaleMin := 0.3;
@export var bloodEffectVelocityScaleMax := 0.5;
## Velocity scale in relation to knockback the player received.
@export var debrisVelocityScale := 0.6;
@export var debrisSizeMin := 2;
@export var debrisSizeMax := 5;

#endregion Export_Variables

@onready var playerAnimator: PlayerAnimator = %PlayerAnimator;
@onready var playerSprite = %Sprite2D;
@onready var oneWayCollisionTimer = %EnableOneWayCollision;
@onready var hurtTimer = %HurtTimer;
@onready var coyoteTimer = %CoyoteTimer;
@onready var soundJump = %AudioStreamJump;
@onready var soundHurt = %AudioStreamHurt;
@onready var soundScream = %AudioStreamScream;
@onready var soundDeath = %AudioStreamDeath;
@onready var soundGuard = %AudioStreamRoyalGuard;
@onready var soundParry = %AudioStreamParry;

var jumpSoundTween;

var state := PLAYER_STATE.GROUNDED;
var currentAnimation := PLAYER_ANIMATION.IDLE;

var royalGuarding := false;
var currentRoyalGuardTime := 0.0;
var currentRoyalGuardCooldown := 0.0;
var currentRoyalGuardIFrameTime := 0.0;

func _ready() -> void:
	soundJump.volume_db = baseSoundJumpVolume;
	
	_enter_state(state);
	
	# Move to the ground
	_apply_gravity(1);
	move_and_slide();

func _physics_process(delta: float) -> void:
	_updateRoyalGuardIFrames(delta);
	_updateRoyalGuardCooldown(delta);
	
	if (state == PLAYER_STATE.GROUNDED):
		_state_grounded(delta);
	elif (state == PLAYER_STATE.JUMPING):
		_state_jumping(delta);
	elif (state == PLAYER_STATE.FALLING):
		_state_falling(delta);
	elif (state == PLAYER_STATE.HURT):
		_state_hurt(delta);
	elif (state == PLAYER_STATE.GUARD_GROUND):
		_state_guard_ground(delta);
	elif (state == PLAYER_STATE.GUARD_AIR):
		_state_guard_air(delta);
	
	if (state != PLAYER_STATE.DEAD):
		move_and_slide();

func takeDamage(knockback: Vector2, damage: int) -> void:
	if (state == PLAYER_STATE.HURT || state == PLAYER_STATE.DEAD || currentRoyalGuardIFrameTime > 0.0): return;
	
	if (royalGuarding):
		_royalGuardParryCallback();
		velocity = knockback * royalGuardKnockbackScale;
		#velocity += knockback * royalGuardKnockbackScale;
		return;
	
	if (GameManager.getPlayerHp() > damage):
		velocity = knockback;
		#velocity += knockback;
		_enter_state(PLAYER_STATE.HURT);
	else:
		_enter_state(PLAYER_STATE.DEAD);
		call_deferred("_createDeathEffects", knockback);
		
	GameManager.removePlayerHp(damage);

func _horizontalMovement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right");
	
	if (direction):
		var velocityToMoveBy = moveVelocity;
		
		if (sign(direction) != sign(velocity.x)):
			velocityToMoveBy = turnAroundVelocity;
			
		velocity.x += direction * velocityToMoveBy * delta;
		#velocity.x = clamp(velocity.x, -maxSpeed, maxSpeed);
		
		#print("Current move velocity: " + str(velocityToMoveBy))
		print("Current velocity X: " + str(velocity.x))
		
		if (velocity.x > 0.0):
			playerAnimator.set_sprite_h_flip(false);
		elif (velocity.x < 0.0):
			playerAnimator.set_sprite_h_flip(true);
	
	if (!direction || (velocity.x > maxSpeed || velocity.x < -maxSpeed)):
		_moveHorizontalVelocityTowardsZero(delta);

func _stopJumpSound() -> void:
	if (state == PLAYER_STATE.JUMPING):
		jumpSoundTween = get_tree().create_tween();
		jumpSoundTween.tween_property(soundJump, "volume_db", jumpSoundStopDb, jumpSoundStopTime);

#region State_Control

func _enter_state(newState: PLAYER_STATE) -> void:
	if (state == newState): return;
	
	royalGuarding = false;
	
	match (newState):
		PLAYER_STATE.GROUNDED:
			_setAnimation(PLAYER_ANIMATION.IDLE);
		
		PLAYER_STATE.JUMPING:
			_setAnimation(PLAYER_ANIMATION.JUMP);
			velocity.y = 0.0;
			velocity.y += jumpVelocity;
			
			soundJump.play(0.0);
			soundJump.volume_db = baseSoundJumpVolume;
			
			if (jumpSoundTween):
					jumpSoundTween.kill();
					
			GameManager.playerJumpedEvent();

		PLAYER_STATE.FALLING:
			# Only start the coyote timer if we were on the ground
			if (state == PLAYER_STATE.GROUNDED):
				coyoteTimer.start();
			
			_setAnimation(PLAYER_ANIMATION.FALL);
			_stopJumpSound();
		
		PLAYER_STATE.HURT:
			_setAnimation(PLAYER_ANIMATION.FALL);
			hurtTimer.start();
			
			_stopJumpSound();
			soundHurt.play();
			
			# Randomly make that shit loud
			if (randf() <= soundScreamLoudChance):
				soundScream.volume_db = soundScreamVolumeLoud;
			else:
				soundScream.volume_db = baseSoundScreamVolume;
			
			soundScream.play();
			
		PLAYER_STATE.DEAD:
			visible = false;
			soundDeath.play();
			soundScream.stop();
			_stopJumpSound();
			
			# Disable the players layer so objects can't interact with him
			set_collision_layer_value(1, false);
			
		PLAYER_STATE.GUARD_GROUND:
			_startRoyalGuard();
			
		PLAYER_STATE.GUARD_AIR:
			_startRoyalGuard();

	state = newState;

func _state_grounded(_delta: float) -> void:
	_horizontalMovement(_delta);
	
	if (abs(velocity.x) > 0.0):
		_setAnimation(PLAYER_ANIMATION.WALK);
	else:
		_setAnimation(PLAYER_ANIMATION.IDLE);
		
	if not is_on_floor():
		_enter_state(PLAYER_STATE.FALLING);
	elif (_checkForRoyalGuard()):
		_enter_state(PLAYER_STATE.GUARD_GROUND);
	elif (Input.is_action_just_pressed("jump")):
		if (Input.is_action_pressed("crouch")):
			set_collision_mask_value(10, false);
			oneWayCollisionTimer.start();
		else:
			_enter_state(PLAYER_STATE.JUMPING);

func _state_jumping(delta: float) -> void:
	_horizontalMovement(delta);
	_apply_gravity(delta);
	
	if (_checkForRoyalGuard()):
		_enter_state(PLAYER_STATE.GUARD_AIR);
	elif (Input.is_action_just_released("jump")):
		velocity.y = 0.0;
		_enter_state(PLAYER_STATE.FALLING);
	elif (velocity.y >= 0.0):
		_enter_state(PLAYER_STATE.FALLING);

func _state_falling(delta: float) -> void:
	_horizontalMovement(delta);
	_apply_gravity(delta);
	
	if (is_on_floor()):
		_enter_state(PLAYER_STATE.GROUNDED);
	elif (_checkForRoyalGuard()):
		_enter_state(PLAYER_STATE.GUARD_AIR);
	elif (!coyoteTimer.is_stopped()):
		if (Input.is_action_just_pressed("jump")):
			_enter_state(PLAYER_STATE.JUMPING);
	# Die when falling out of the screen
	elif (position.y > %PlayerCamera.limit_bottom + 8):
		takeDamage(Vector2(), 99);
		
func _state_hurt(delta: float) -> void:
	_moveHorizontalVelocityTowardsZero(delta);
	_apply_gravity(delta);
	
	if (hurtTimer.is_stopped()): #_getHorizontalVelocity() == 0.0 && 
		_enter_state(PLAYER_STATE.FALLING);
	
func _state_guard_ground(delta: float) -> void:
	_moveHorizontalVelocityTowardsZero(delta);
	_apply_gravity(delta);
	_updateRoyalGuard(delta);
		
func _state_guard_air(delta: float) -> void:
	# Allow the  player to move at a reduced velocity
	_horizontalMovement(delta);
	velocity.x *= royalGuardHorizontalVelocityScale;
	_apply_gravity(delta);
	
	if (is_on_floor()):
		state = PLAYER_STATE.GUARD_GROUND;
	else:
		_updateRoyalGuard(delta);
	
#endregion State_Control

#region Animation

func _setAnimation(animation: PLAYER_ANIMATION) -> void:
	currentAnimation = animation;
	playerAnimator.play_animation(ANIMATION_NAMES[animation]);

func getCurrentAnimation() -> String:
	return ANIMATION_NAMES[currentAnimation];

func getHFlip() -> bool:
	return playerAnimator.get_sprite_h_flip();

#endregion Animation
	
#region Royal_Guard

func _startRoyalGuard() -> void:
	royalGuarding = true;
	currentRoyalGuardTime = royalGuardTime;
	currentRoyalGuardIFrameTime = 0.0;	# Reset iframe time when royal guard is triggered again
	soundGuard.play();
	#velocity.x = 0.0;
	_setAnimation(PLAYER_ANIMATION.GUARD);
	modulate = Color(1, 1, 1, 1);
			
func _updateRoyalGuardIFrames(delta: float) -> void:
	if (currentRoyalGuardIFrameTime > 0.0):
		currentRoyalGuardIFrameTime = max(currentRoyalGuardIFrameTime - delta, 0.0);
		
		if (currentRoyalGuardIFrameTime == 0.0):
			modulate = Color(1, 1, 1, 1);
			
func _updateRoyalGuardCooldown(delta: float) -> void:
	currentRoyalGuardCooldown = max(currentRoyalGuardCooldown - delta, 0.0);

func _checkForRoyalGuard() -> bool:
	# Only allow royal guard on DMD
	if (GameManager.getDifficulty() != GameManager.DIFFICULTY.DMD): return false;
	
	if (currentRoyalGuardCooldown == 0.0 && Input.is_action_just_pressed("guard")):
		return true;
		
	return false;

func _updateRoyalGuard(delta: float) -> void:
	currentRoyalGuardTime -= delta;
	
	if (currentRoyalGuardTime <= 0.0):
		_endRoyalGuard();
		currentRoyalGuardCooldown = royalGuardCooldown;

func _royalGuardParryCallback() -> void:
	currentRoyalGuardTime = 0.0;
	currentRoyalGuardIFrameTime = royalGuardInvincibilityTime;
	modulate = Color(1, 0.9, 0, 1);
	soundParry.play();
	_endRoyalGuard();

func _endRoyalGuard() -> void:
	currentRoyalGuardTime = 0.0;
	
	if (state == PLAYER_STATE.GUARD_GROUND):
		_enter_state(PLAYER_STATE.GROUNDED);
	else:
		_enter_state(PLAYER_STATE.FALLING);

#endregion

#region Physics

func _apply_gravity(delta: float) -> void:
	velocity += get_gravity() * delta;

func _moveHorizontalVelocityTowardsZero(delta: float) -> void:
	if (velocity.x > 0.0):
		velocity.x = max(velocity.x - stopVelocity * delta, 0.0);
	elif (velocity.x < 0.0):
		velocity.x = min(velocity.x + stopVelocity * delta, 0.0);
	
	#velocity.x = move_toward(velocity.x, 0, speedStopLerp);
	
#endregion Physics
	
#region Effects

func _createDeathEffects(knockback: Vector2) -> void:
	GameManager.createBloodParticles(global_position);
	GameManager.createBloodEffect(global_position, knockback, bloodEffectDegreesRange, bloodEffectVelocityScaleMin, bloodEffectVelocityScaleMax, bloodEffectCountMin, bloodEffectCountMax);
	GameManager.createDebris(global_position + Vector2(-9.0, -9.0), playerSprite.get_texture(), playerSprite.flip_h, 1, knockback * debrisVelocityScale, Vector2(7.0, 16.0), Vector2(18.0, 16.0), debrisSizeMin, debrisSizeMax)

#endregion Effects

func _on_enable_one_way_collision_timeout() -> void:
	set_collision_mask_value(10, true);
