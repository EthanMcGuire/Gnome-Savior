extends LevelWarp

func _startTransition() -> void:
	super();
	%AudioStreamDoorOpen.play();

func _on_audio_stream_door_open_finished() -> void:
	%AudioStreamDoorClose.play();

func _on_audio_stream_door_close_finished() -> void:
	queue_free();
