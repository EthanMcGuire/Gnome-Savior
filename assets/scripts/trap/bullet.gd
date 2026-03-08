extends Trap

@export var moveSpeed := 300.0;

func _physics_process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * moveSpeed * delta;

func _on_body_entered(body: Node2D) -> void:
	if (_dealDamage(body, global_position)):
		# TODO
		# Play sound here?
		pass
		
	queue_free();


func _on_despawn_timer_timeout() -> void:
	queue_free();
