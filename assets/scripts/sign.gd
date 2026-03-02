extends Area2D
class_name Sign

@export var text := "Hello world.";

func _on_body_entered(body: Node2D) -> void:
	if (body is PlayerController):
		GameManager.showSign(text);

func _on_body_exited(body: Node2D) -> void:
	if (body is PlayerController):
		GameManager.hideSign();
