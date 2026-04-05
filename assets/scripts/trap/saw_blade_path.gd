extends Path2D

@export var dmdOnly := false;

@export var looping := false;
@export var deltaSpeedPixelsStart := 64.0;
@export var deltaSpeedPixelsReturn := 64.0;	# Only matters if looping is disabled
@export var startDelay := 0.0;
@export var moveDelayStart := 0.0;
@export var moveDelayReturn := 0.0;	# Only matters if looping is disabled
@export var easeType := Tween.EaseType.EASE_IN_OUT;
@export var transitionType := Tween.TransitionType.TRANS_QUAD;

var started := false;

func _ready() -> void:
	if (dmdOnly && GameManager.getDifficulty() != GameManager.DIFFICULTY.DMD):
		queue_free();
	
	if (startDelay <= 0.0):
		_start();
	else:
		%StartTimer.start(startDelay);

func _start() -> void:
	if (started): return;
	
	var tween;
	var moveTime;
	var pathLength;

	started = true;

	pathLength = curve.get_baked_length();
	
	if (pathLength <= 0.0): return;
	
	tween = get_tree().create_tween().set_loops();
	tween.bind_node(self);
	
	moveTime = pathLength / deltaSpeedPixelsStart;
	tween.tween_property(%PathFollow2D, "progress_ratio", 1.0, moveTime).set_delay(moveDelayStart).set_ease(easeType).set_trans(transitionType);
	
	if (!looping):
		moveTime = pathLength / deltaSpeedPixelsReturn;
		tween.tween_property(%PathFollow2D, "progress_ratio", 0.0, moveTime).set_delay(moveDelayReturn).set_ease(easeType).set_trans(transitionType);
	else:
		tween.tween_property(%PathFollow2D, "progress_ratio", 0.0, 0.0);


func _on_start_timer_timeout() -> void:
	_start();
