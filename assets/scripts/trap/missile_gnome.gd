extends Trap

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

const SPEED := 500.0;

var dead := false;

func _physics_process(delta: float) -> void:
	global_position += Vector2.RIGHT.rotated(rotation) * SPEED * delta;

func _explode() -> void:
	var knockback;
	
	dead = true;
	visible = false;
	
	%AudioStreamDeath.play();
	%AudioStreamScream.stop();
	%DestroyTimer.start();
	
	knockback = Vector2.RIGHT.rotated(rotation + 3.14) * SPEED;
	call_deferred("_createDeathEffects", knockback);
	
func _createDeathEffects(knockback: Vector2) -> void:
	GameManager.createBloodParticles(global_position);
	GameManager.createBloodEffect(global_position, knockback, bloodEffectDegreesRange, bloodEffectVelocityScaleMin, bloodEffectVelocityScaleMax, bloodEffectCountMin, bloodEffectCountMax);
	GameManager.createDebris(global_position + Vector2(-10.0, -16.0), %Gnome.get_texture(), %Gnome.flip_h, 1, knockback * debrisVelocityScale, Vector2(6.0, 0.0), Vector2(22.0, 32.0), debrisSizeMin, debrisSizeMax)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (dead): return;
	
	if (body is PlayerController):
		_dealDamage(body, global_position);
	_explode();

func _on_destroy_timer_timeout() -> void:
	queue_free();
