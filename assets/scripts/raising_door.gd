extends Node2D
class_name RaisingDoor

const SPEED := 64.0;

var moveAmount := 128.0;
var raising := false;

func _ready() -> void:
	global_position.y += moveAmount;
	
func _physics_process(delta: float) -> void:
	if (raising && moveAmount > 0):
		var amountToMove;
		
		amountToMove = min(SPEED * delta, moveAmount);
		
		moveAmount -= amountToMove;
		global_position.y -= amountToMove;
	
func raise() -> void:
	raising = true;
