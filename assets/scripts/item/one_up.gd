extends Collectable
class_name OneUp;

func _collect() -> void:
	GameManager.addLives(count);
	queue_free();

func _on_body_entered(body: Node2D) -> void:
	_getCollected(body);
