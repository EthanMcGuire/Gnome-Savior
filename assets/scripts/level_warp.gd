extends Area2D
class_name LevelWarp

@export var warpLevel: String;

func _ready() -> void:
	if (warpLevel == ""):
		print("LevelWarp: Warning, warpLevel has not been set!!!");

func _on_body_entered(body: Node2D) -> void:
	if (body is PlayerController):
		_startTransition();

func _startTransition() -> void:
	if (warpLevel == ""): return;
	
	GameManager.startLevelTransition(load(warpLevel));
