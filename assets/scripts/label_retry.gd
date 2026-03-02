extends Label
class_name LabelRetry;

var centerLocationY: float;

func _ready() -> void:
	centerLocationY = position.y;
	visible = false;

func _physics_process(delta: float) -> void:
	if (visible):
		position.y = lerp(position.y, centerLocationY, 0.2);
	else:
		position.y = lerp(position.y, centerLocationY + get_viewport().size.y, 0.2);
