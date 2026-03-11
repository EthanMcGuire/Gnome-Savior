extends Path2D
class_name MovingPlatform;

## Is this a one way platform?
@export var oneWay := true;
## Whether to loop or move back and forth
@export var looping := false;
## Wait for the player before moving
@export var waitForPlayer := false;
## Stop once the end of the path has been reached
@export var stopAtEnd := false;
@export var deltaSpeedPixelsStart := 64.0;
@export var deltaSpeedPixelsReturn := 64.0;	# Only matters if looping is disabled
@export var moveDelayStart := 0.0;
@export var moveDelayReturn := 0.0;	# Only matters if looping is disabled
@export var easeType := Tween.EaseType.EASE_IN;
@export var transitionType := Tween.TransitionType.TRANS_LINEAR;

var started := false;

func _ready() -> void:
	# Disable one way collision
	if (!oneWay):
		%CollisionShape2D.one_way_collision = false;
		%AnimatableBody2D.set_collision_mask_value(9, true);
		%AnimatableBody2D.set_collision_mask_value(10, false);
	
	if (!waitForPlayer):
		_start();

func _start():
	if (started): return;
	
	var tween;
	var moveTime;
	var pathLength;
	
	started = true;
	
	pathLength = curve.get_baked_length();
	tween = get_tree().create_tween().set_loops(1 if stopAtEnd else 0);
	
	moveTime = pathLength / deltaSpeedPixelsStart;
	tween.tween_property(%PathFollow2D, "progress_ratio", 1.0, moveTime).set_delay(moveDelayStart).set_ease(easeType).set_trans(transitionType);
	
	if (!stopAtEnd):
		if (!looping):
			moveTime = pathLength / deltaSpeedPixelsReturn;
			tween.tween_property(%PathFollow2D, "progress_ratio", 0.0, moveTime).set_delay(moveDelayReturn).set_ease(easeType).set_trans(transitionType);
		else:
			tween.tween_property(%PathFollow2D, "progress_ratio", 0.0, 0.0);


func _on_area_player_body_entered(body: Node2D) -> void:
	if (body is PlayerController):
		_start();
