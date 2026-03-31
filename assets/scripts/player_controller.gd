extends CharacterBody2D
class_name PlayerController

enum PLAYER_STATE {
	GROUNDED,
	JUMPING,
	FALLING,
	HURT,
	DEAD
};

enum GRAVITY {
	DOWN,
	UP,
	LEFT,
	RIGHT
};

#region Export_Variables

@export_group("Physics")
@export var speed = 136.0;
@export var speedStopLerp = 32.0;
@export var jumpVelocity = -300.0;

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
@export var bloodEffectVelocityScaleMin := 0.2;
@export var bloodEffectVelocityScaleMax := 0.35;
## Velocity scale in relation to knockback the player received.
@export var debrisVelocityScale := 0.5;
@export var debrisSizeMin := 2;
@export var debrisSizeMax := 5;

#endregion Export_Variables

@onready var playerAnimator = %PlayerAnimator;
@onready var playerSprite = %Sprite2D;
@onready var oneWayCollisionTimer = %EnableOneWayCollision;
@onready var hurtTimer = %HurtTimer;
@onready var soundJump = %AudioStreamJump;
@onready var soundHurt = %AudioStreamHurt;
@onready var soundScream = %AudioStreamScream;
@onready var soundDeath = %AudioStreamDeath;

var jumpSoundTween;

var state := PLAYER_STATE.GROUNDED;
var gravity := GRAVITY.DOWN;

func _ready() -> void:
	_enter_state(state);
	setGravity(gravity);
	soundJump.volume_db = baseSoundJumpVolume;

func _physics_process(delta: float) -> void:
	if (state == PLAYER_STATE.GROUNDED):
		_state_grounded(delta);
	elif (state == PLAYER_STATE.JUMPING):
		_state_jumping(delta);
	elif (state == PLAYER_STATE.FALLING):
		_state_falling(delta);
	elif (state == PLAYER_STATE.HURT):
		_state_hurt(delta);
	
	if (state != PLAYER_STATE.DEAD):
		move_and_slide();

func takeDamage(knockback: Vector2, damage: int) -> void:
	if (state == PLAYER_STATE.HURT || state == PLAYER_STATE.DEAD): return;
	
	if (GameManager.getPlayerHp() > damage):
		_addHorizontalVelocity(knockback.x);
		_addVerticalVelocity(knockback.y);
		_enter_state(PLAYER_STATE.HURT);
	else:
		_enter_state(PLAYER_STATE.DEAD);
		call_deferred("_createDeathEffects", knockback);
		
	GameManager.removePlayerHp(damage);

func _horizontalMovement() -> void:
	var direction := Input.get_axis("move_left", "move_right");
	
	if (direction):
		_setHorizontalVelocity(direction * speed);
		
		playerAnimator.set_sprite_h_flip(direction < 0.0);
	else:
		_moveHorizontalVelocityTowardsZero();

func _stopJumpSound() -> void:
	if (state == PLAYER_STATE.JUMPING):
		jumpSoundTween = get_tree().create_tween();
		jumpSoundTween.tween_property(soundJump, "volume_db", jumpSoundStopDb, jumpSoundStopTime);

#region State_Control

func _enter_state(newState: PLAYER_STATE) -> void:
	if (state == newState): return;
	
	match (newState):
		PLAYER_STATE.GROUNDED:
			playerAnimator.play_animation_idle();
		
		PLAYER_STATE.JUMPING:
			playerAnimator.play_animation_jump();
			_addVerticalVelocity(jumpVelocity);
			
			soundJump.play(0.0);
			soundJump.volume_db = baseSoundJumpVolume;
			
			if (jumpSoundTween):
					jumpSoundTween.kill();

		PLAYER_STATE.FALLING:
			playerAnimator.play_animation_falling();
			_stopJumpSound();
		
		PLAYER_STATE.HURT:
			playerAnimator.play_animation_falling();
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

	state = newState;

func _state_grounded(_delta: float) -> void:
	_horizontalMovement();
	
	if (abs(_getHorizontalVelocity()) > 0.0):
		playerAnimator.play_animation_moving();
	else:
		playerAnimator.play_animation_idle();
		
	if not is_on_floor():
		_enter_state(PLAYER_STATE.FALLING);
	elif (Input.is_action_just_pressed("jump")):
		if (Input.is_action_pressed("crouch")):
			set_collision_mask_value(10, false);
			oneWayCollisionTimer.start();
		else:
			_enter_state(PLAYER_STATE.JUMPING);

func _state_jumping(delta: float) -> void:
	_horizontalMovement();
	_apply_gravity(delta);
	
	if (Input.is_action_just_released("jump")):
		_setVerticalVelocity(0.0);
		_enter_state(PLAYER_STATE.FALLING);
	elif (_getVerticalVelocity() >= 0.0):
		_enter_state(PLAYER_STATE.FALLING);

func _state_falling(delta: float) -> void:
	_horizontalMovement();
	_apply_gravity(delta);
	
	if (is_on_floor()):
		_enter_state(PLAYER_STATE.GROUNDED);
	# Die when falling out of the screen
	elif (position.y > %PlayerCamera.limit_bottom + 8):
		takeDamage(Vector2(), 99);
		
func _state_hurt(delta: float) -> void:
	_moveHorizontalVelocityTowardsZero();
	_apply_gravity(delta);
	
	if (hurtTimer.is_stopped()): #_getHorizontalVelocity() == 0.0 && 
		_enter_state(PLAYER_STATE.FALLING);
	
#endregion State_Control
		
#region Gravity

#func _process(delta: float) -> void:
	#if (Input.is_action_just_pressed("gravity")):
		#_switchGravity();
#
#func _switchGravity() -> void:
	#match (gravity):
		#GRAVITY.DOWN:
			#setGravity(GRAVITY.UP);
		#GRAVITY.UP:
			#setGravity(GRAVITY.LEFT);
		#GRAVITY.LEFT:
			#setGravity(GRAVITY.RIGHT);
		#GRAVITY.RIGHT:
			#setGravity(GRAVITY.DOWN);

func setGravity(newGravity: GRAVITY) -> void:
	gravity = newGravity;
	
	match (gravity):
		GRAVITY.DOWN:
			up_direction = Vector2(0.0, -1.0);
			rotation_degrees = 0.0;
		GRAVITY.UP:
			up_direction = Vector2(0.0, 1.0);
			rotation_degrees = 180.0;
		GRAVITY.LEFT:
			up_direction = Vector2(1.0, 0.0);
			rotation_degrees = 90.0;
		GRAVITY.RIGHT:
			up_direction = Vector2(-1.0, 0.0);
			rotation_degrees = -90.0;

func _apply_gravity(delta: float) -> void:
	velocity += _getGravityVector() * delta;

func _getGravityVector() -> Vector2:
	var gravVector = get_gravity();
	
	match (gravity):
		GRAVITY.UP:
			gravVector.y *= -1.0;
		GRAVITY.LEFT:
			gravVector.x = gravVector.y * -1.0;
			gravVector.y = 0.0;
		GRAVITY.RIGHT:
			gravVector.x = gravVector.y;
			gravVector.y = 0.0;
	
	return gravVector;

func _getHorizontalVelocity() -> float:
	match (gravity):
		GRAVITY.DOWN:
			return velocity.x;
		GRAVITY.UP:
			return velocity.x;	# -velocity.x
		GRAVITY.LEFT:
			return velocity.y;
		GRAVITY.RIGHT:
			return -velocity.y;
	
	return 0.0;
			
func _getVerticalVelocity() -> float:
	match (gravity):
		GRAVITY.DOWN:
			return velocity.y;
		GRAVITY.UP:
			return -velocity.y;
		GRAVITY.LEFT:
			return -velocity.x;
		GRAVITY.RIGHT:
			return velocity.x;
			
	return 0.0;

func _setHorizontalVelocity(newVelocity: float) -> void:
	match (gravity):
		GRAVITY.DOWN:
			velocity.x = newVelocity;
		GRAVITY.UP:
			velocity.x = newVelocity;	# -newVelocity.x
		GRAVITY.LEFT:
			velocity.y = newVelocity;
		GRAVITY.RIGHT:
			velocity.y = -newVelocity;
			
func _addHorizontalVelocity(addVelocity: float) -> void:
	match (gravity):
		GRAVITY.DOWN:
			velocity.x += addVelocity;
		GRAVITY.UP:
			velocity.x += addVelocity;	# -newVelocity.x
		GRAVITY.LEFT:
			velocity.y += addVelocity;
		GRAVITY.RIGHT:
			velocity.y += -addVelocity;
			
func _setVerticalVelocity(newVelocity: float) -> void:
	match (gravity):
		GRAVITY.DOWN:
			velocity.y = newVelocity;
		GRAVITY.UP:
			velocity.y = -newVelocity;
		GRAVITY.LEFT:
			velocity.x = -newVelocity;
		GRAVITY.RIGHT:
			velocity.x = newVelocity;
			
func _addVerticalVelocity(addVelocity: float) -> void:
	match (gravity):
		GRAVITY.DOWN:
			velocity.y += addVelocity;
		GRAVITY.UP:
			velocity.y += -addVelocity;
		GRAVITY.LEFT:
			velocity.x += -addVelocity;
		GRAVITY.RIGHT:
			velocity.x += addVelocity;

func _moveHorizontalVelocityTowardsZero() -> void:
	match (gravity):
		GRAVITY.DOWN:
			velocity.x = move_toward(velocity.x, 0, speedStopLerp);
		GRAVITY.UP:
			velocity.x = move_toward(velocity.x, 0, speedStopLerp);
		GRAVITY.LEFT:
			velocity.y = move_toward(velocity.y, 0, speedStopLerp);
		GRAVITY.RIGHT:
			velocity.y = move_toward(velocity.y, 0, speedStopLerp);
	
#endregion Gravity

#region Effects

func _createDeathEffects(knockback: Vector2) -> void:
	GameManager.createBloodParticles(global_position);
	GameManager.createBloodEffect(global_position, knockback, bloodEffectDegreesRange, bloodEffectVelocityScaleMin, bloodEffectVelocityScaleMax, bloodEffectCountMin, bloodEffectCountMax);
	GameManager.createDebris(global_position + Vector2(-9.0, -9.0), playerSprite.get_texture(), playerSprite.flip_h, 1, knockback * debrisVelocityScale, Vector2(7.0, 16.0), Vector2(18.0, 16.0), debrisSizeMin, debrisSizeMax)

#endregion Effects

func _on_enable_one_way_collision_timeout() -> void:
	set_collision_mask_value(10, true);
