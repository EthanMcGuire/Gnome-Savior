extends Area2D


func endGame() -> void:
	GameManager.endGame();

func _on_body_entered(body: Node2D) -> void:
	call_deferred("endGame");
