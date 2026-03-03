extends Node2D
class_name SceneStartTransition;

@export var transitionTime := 0.75;

func _ready() -> void:
	var tween;
	var color: Color = Color(0.0, 0.0, 0.0, 0.0);
	
	$CanvasLayer.layer = 1000;	# Move to front
	
	tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	
	tween.tween_property(%ColorRect, "color", color, transitionTime);
	tween.tween_callback(endTranstition);

func endTranstition() -> void:
	queue_free();
