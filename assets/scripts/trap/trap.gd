extends Node2D
class_name Trap

@export var damage := 1;
@export var knockback := 400.0;

func _dealDamage(body: Node2D, knockbackPos: Vector2) -> void:
	if (body.has_method("takeDamage")):
		var knockbackDir;
		
		knockbackDir = body.global_position - knockbackPos;
		knockbackDir = knockbackDir.normalized();
		
		body.takeDamage(knockbackDir * knockback, damage);
