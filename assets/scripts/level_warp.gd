extends Area2D
class_name LevelWarp

@export var warpLevel := "res://assets/scenes/Levels/level_1.tscn";

func _on_body_entered(body: Node2D) -> void:
	if (body is PlayerController):
		_startTransition();

func _startTransition() -> void:
	GameManager.startLevelTransition(warpLevel);
