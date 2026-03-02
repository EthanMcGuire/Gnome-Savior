extends Node2D
class_name PortalEndpoint


func _ready() -> void:
	visible = false;

func warpPlayer() -> void:
	%AudioStreamPlayer2D.play();
	GameManager.setPlayerPosition(global_position);
