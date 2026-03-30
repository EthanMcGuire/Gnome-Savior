extends Trap

@export var speed := 150.0;

func _process(delta: float) -> void:
	var bodies = %Area2D.get_overlapping_bodies();
	
	for body in bodies:
		_dealDamage(body, global_position);

func _physics_process(delta: float) -> void:
	var vecDir = GameManager.getPlayerPosition() - global_position;
	
	# So the dog doesn't jitter after killing the player
	if (vecDir.length() <= 5.0): return;
	
	vecDir = vecDir.normalized();
	
	global_position += speed * vecDir * delta;

func _on_bark_timer_timeout() -> void:
	%AudioStreamPlayer2D.play();
