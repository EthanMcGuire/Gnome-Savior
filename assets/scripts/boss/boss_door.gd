extends Node2D
class_name BossDoor

const MOVE_SPEED = 16.0;	# Pixels per second

@export var spaceToMoveX := 32.0;
var enabled := false;

func _ready() -> void:
	visible = false;
	global_position.y -= 48;

func enable() -> void:
	visible = true;
	enabled = true;
	global_position.y += 48;

func _physics_process(delta: float) -> void:
	if (!enabled || spaceToMoveX <= 0.0): return;
	
	var moveAmount;
	
	moveAmount = min(MOVE_SPEED * delta, spaceToMoveX);
	
	spaceToMoveX -= moveAmount;
	global_position.x += moveAmount;
