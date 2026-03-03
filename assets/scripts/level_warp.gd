extends Area2D
class_name LevelWarp

@export var warpLevel: String;

func _ready() -> void:
	if (!warpLevel):
		print("LevelWarp: warpLevel has not been set!!!");
	
	assert(warpLevel);

func _on_body_entered(body: Node2D) -> void:
	if (body is PlayerController):
		_startTransition();

func _startTransition() -> void:
	GameManager.startLevelTransition(load(warpLevel));
