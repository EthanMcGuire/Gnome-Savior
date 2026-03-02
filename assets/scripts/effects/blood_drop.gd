extends Area2D

@export var velocityY := 32.0;
@export var slowDownLerp := 32.0;
## Horizontal velocity wiggle
@export var wiggle := 0.1;

var onTile := false;

#func setVelocity(_velocityY: float) -> void:
	#velocityY = _velocityY;
	#visible = false;

func _process(delta: float) -> void:
	if (get_overlapping_bodies().size() > 0):
		# Draw blood
		GameManager.drawBlood(global_position);

func _physics_process(delta: float) -> void:
	var moveVelocity := Vector2(randf_range(-wiggle, wiggle), velocityY);
	
	position += moveVelocity * delta;
	
	velocityY = move_toward(velocityY, 0.0, slowDownLerp * delta);
	
	if (velocityY == 0.0):
		queue_free();
