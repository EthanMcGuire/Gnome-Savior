extends Node2D
class_name SceneEndTransition;

var nextScene: PackedScene;
var transitionStarted := false;

func startTransition(transitionTime: float, _nextScene: PackedScene) -> void:
	var tween;
	var color: Color = Color(0.0, 0.0, 0.0, 1.0);
	
	if (transitionStarted): return;
	
	transitionStarted = true;
	get_tree().paused = true;
	
	tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property(%ColorRect, "color", color, transitionTime);
	tween.tween_callback(endTranstition);
	
	nextScene = _nextScene;

func endTranstition() -> void:
	queue_free();
	get_tree().paused = false;
	GameManager.loadLevel(nextScene);
