extends Area2D
class_name GravitySwapper;

@export var gravityDirection := PlayerController.GRAVITY.UP;

func _on_body_entered(body: Node2D) -> void:
	if (body is PlayerController):
		body.setGravity(gravityDirection);

func _on_body_exited(body: Node2D) -> void:
	if (body is PlayerController):
		body.setGravity(PlayerController.GRAVITY.DOWN);
