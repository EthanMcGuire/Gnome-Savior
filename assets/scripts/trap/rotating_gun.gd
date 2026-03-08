extends Node2D

@export var rotationLerp := 0.2;

func _process(delta: float) -> void:
	var playerPos: Vector2;
	var dirVector: Vector2;
	
	playerPos = GameManager.getPlayerPosition();
	dirVector = playerPos - global_position;
	
	%Gun.rotation = lerp_angle(%Gun.rotation, dirVector.angle(), rotationLerp);
