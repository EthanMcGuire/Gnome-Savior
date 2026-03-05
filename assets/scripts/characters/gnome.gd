extends CharacterBody2D
class_name Gnome

enum GNOME_STATE {
	GNOME_STATE_HELP,
	GNOME_STATE_FREE,
	GNOME_STATE_HURT,
	GNOME_STATE_DEAD
}

@export_group("Movement")
@export var moveSpeed := 96.0;
@export var speedStopLerp := 64.0;

@export_group("Sound")
@export var laughTimeMin := 1.0;
@export var laughTimeMax := 3.0;

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
@export var debrisSizeMax := 4;

var state := GNOME_STATE.GNOME_STATE_DEAD;
var moveDirection := 1.0;
var hp = 2;

func _ready() -> void:
	_enterState(GNOME_STATE.GNOME_STATE_HELP);
	_startLaughTimer();

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta;
	
	if (state == GNOME_STATE.GNOME_STATE_FREE):
		velocity.x = moveSpeed * moveDirection;
		
		if (move_and_slide() && is_on_wall()):
			moveDirection *= -1;
			%Sprite2D.flip_h = !%Sprite2D.flip_h;
	elif (state == GNOME_STATE.GNOME_STATE_HURT):
		velocity.x = move_toward(velocity.x, 0, speedStopLerp * delta);
		
		move_and_slide();
		
		if (velocity.x == 0.0 && %HurtTimer.is_stopped()):
			_enterState(GNOME_STATE.GNOME_STATE_FREE);

func _enterState(newState: GNOME_STATE) -> void:
	if (state == newState): return;
	
	match (newState):
		GNOME_STATE.GNOME_STATE_HELP:
			%AnimationPlayer.play("help");
			%Sprite2D.flip_h = false;
			
		GNOME_STATE.GNOME_STATE_FREE:
			%AnimationPlayer.play("walk");
				
			velocity.y = 0.0;
			
		GNOME_STATE.GNOME_STATE_HURT:
			%HurtTimer.start();
			
			_startLaughTimer();
			%AudioStreamLaugh.stop();
			%AudioStreamScream.play();
			
		GNOME_STATE.GNOME_STATE_DEAD:
			visible = false;
			%LaughTimer.stop();
			%AudioStreamLaugh.stop();
			%AudioStreamScream.stop();
			%AudioStreamDeath.play();
			
	state = newState;
	
func freeGnome() -> void:
	%AudioStreamFree.play();
	_enterState(GNOME_STATE.GNOME_STATE_FREE);
	
	if (randi_range(0, 1) == 0):
		moveDirection = -1;
		%Sprite2D.flip_h = false;
	else:
		moveDirection = 1;
		%Sprite2D.flip_h = true;
	
func takeDamage(knockback: Vector2, damage: int) -> void:
	if (state != GNOME_STATE.GNOME_STATE_FREE): return;
	
	hp -= damage;
	
	if (hp > 0):
		velocity += knockback;
		_enterState(GNOME_STATE.GNOME_STATE_HURT);
	else:
		_enterState(GNOME_STATE.GNOME_STATE_DEAD);
		call_deferred("_createDeathEffects", knockback);

#region Effects

func _createDeathEffects(knockback: Vector2) -> void:
	GameManager.createBloodParticles(global_position);
	GameManager.createBloodEffect(global_position, knockback, bloodEffectDegreesRange, bloodEffectVelocityScaleMin, bloodEffectVelocityScaleMax, bloodEffectCountMin, bloodEffectCountMax);
	GameManager.createDebris(global_position + Vector2(-10.0, -16.0), %Sprite2D.get_texture(), %Sprite2D.flip_h, knockback * debrisVelocityScale, Vector2(6.0, 0.0), Vector2(22.0, 32.0), debrisSizeMin, debrisSizeMax)

#endregion Effects

#region Laugh

func _startLaughTimer() -> void:
	%LaughTimer.start(randf_range(laughTimeMin, laughTimeMax));

func _on_laugh_timer_timeout() -> void:
	%AudioStreamLaugh.play();
	_startLaughTimer();
	
#endregion Laugh
