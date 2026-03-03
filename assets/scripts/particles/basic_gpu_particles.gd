extends GPUParticles2D

func _ready() -> void:
	emitting = true;

func _on_free_timer_timeout() -> void:
	queue_free();
