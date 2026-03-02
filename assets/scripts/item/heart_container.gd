extends Collectable
class_name HeartContainer;

@export var heartContainerName := "first_heart_container";

func _ready() -> void:
	if (GameManager.checkHeartContainerCollected(heartContainerName)):
		queue_free();

func _collect() -> void:
	GameManager.heartContainerCollected(heartContainerName);
	$AudioStreamPlayer2D.play();
	visible = false;

func _on_audio_stream_player_2d_finished() -> void:
	queue_free();

func _on_body_entered(body: Node2D) -> void:
	_getCollected(body);
