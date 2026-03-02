extends Collectable
class_name Coin;

func _collect() -> void:
	GameManager.addCoins(count);
	%AnimationPlayer.play("collect");
	$AudioStreamPlayer2D.play();
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "collect"):
		visible = false;

func _on_audio_stream_player_2d_finished() -> void:
	queue_free();

func _on_body_entered(body: Node2D) -> void:
	_getCollected(body);
