extends Trap


func _on_area_2d_body_entered(body: Node2D) -> void:
	_dealDamage(body, %Area2D.global_position)
