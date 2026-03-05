extends Trap

@export var looping := false;
@export var deltaSpeedPixelsStart := 64.0;
@export var deltaSpeedPixelsReturn := 64.0;	# Only matters if looping is disabled
@export var moveDelayStart := 0.0;
@export var moveDelayReturn := 0.0;	# Only matters if looping is disabled
@export var easeType := Tween.EaseType.EASE_IN;
@export var transitionType := Tween.TransitionType.TRANS_LINEAR;

func _ready() -> void:
	var tween;
	var moveTime;
	var pathLength;

	pathLength = %Path2D.curve.get_baked_length();
	tween = get_tree().create_tween().set_loops();
	
	moveTime = pathLength / deltaSpeedPixelsStart;
	tween.tween_property(%PathFollow2D, "progress_ratio", 1.0, moveTime).set_delay(moveDelayStart).set_ease(easeType).set_trans(transitionType);
	
	if (!looping):
		moveTime = pathLength / deltaSpeedPixelsReturn;
		tween.tween_property(%PathFollow2D, "progress_ratio", 0.0, moveTime).set_delay(moveDelayReturn).set_ease(easeType).set_trans(transitionType);
	else:
		tween.tween_property(%PathFollow2D, "progress_ratio", 0.0, 0.0);


func _on_trap_body_entered(body: Node2D) -> void:
	_dealDamage(body, %Trap.global_position);
