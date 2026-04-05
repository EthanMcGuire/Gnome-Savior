extends Label
class_name LabelRetry;

var centerLocationY: float;

var usingGamepad := false;

func _ready() -> void:
	centerLocationY = position.y;
	visible = false;

func _process(delta: float) -> void:
	if (!visible): return;
	
	var new = GameManager.getUsingGamepad();
	
	if (usingGamepad != new):
		usingGamepad = new;
		
		if (usingGamepad):
			text = "PRESS SELECT TO RETRY";
		else:
			text = "PRESS R TO RETRY";

func _physics_process(delta: float) -> void:
	if (visible):
		position.y = lerp(position.y, centerLocationY, 0.2);
	else:
		position.y = lerp(position.y, centerLocationY + get_viewport().size.y, 0.2);
