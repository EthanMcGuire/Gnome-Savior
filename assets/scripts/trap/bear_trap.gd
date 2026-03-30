extends Trap
class_name BearTrap

var isOpen = false;

func _open() -> void:
	isOpen = true;
	
	%SpriteClosed.visible = true;
	%SpriteOpen.visible = false;
	%AudioStreamPlayer2D.play();
	
func _on_body_entered(body: Node2D) -> void:
	if (!isOpen):
		_open();
		_dealDamage(body, global_position)
