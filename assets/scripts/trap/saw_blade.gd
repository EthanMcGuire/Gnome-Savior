extends Trap

func _on_body_entered(body: Node2D) -> void:
	_dealDamage(body, global_position);
