extends Trap

const BASE_OFFSET = -8.0;
const SIZE = 16.0;

@export var startDelay := 0.0;
@export var returnTime := 1.0;
@export var returnDelay := 0.25;
@export var stabTime := 0.2;
@export var stabDelay := 0.5;

func _ready() -> void:
	if (startDelay > 0.0):
		%StartDelayTimer.start(startDelay);
	else:
		_start();
	
func _start() -> void:
	var tween;
	
	tween = get_tree().create_tween().set_loops(0);
	
	tween.tween_method(_setSpikeOffset, BASE_OFFSET, BASE_OFFSET + 16.0, returnTime).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).set_delay(returnDelay);
	tween.tween_callback(_playSound).set_delay(stabDelay);
	tween.tween_method(_setSpikeOffset, BASE_OFFSET + 16.0, BASE_OFFSET, stabTime).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD);
	
	
func _setSpikeOffset(offset: float) -> void:
	var height;
	
	height = SIZE - (offset + (BASE_OFFSET * -1.0));	# Height will remain at 16 if offset = BASE_OFFSET
	
	%Area2D.position.y = offset;
	%Sprite2D.region_rect = Rect2(0.0, 0.0, SIZE, height);

func _playSound() -> void:
	%AudioStreamPlayer2D.play();
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	_dealDamage(body, %Area2D.global_position)

func _on_start_delay_timer_timeout() -> void:
	_start();
