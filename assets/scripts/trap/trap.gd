extends Node2D
class_name Trap

@export var damage := 1;
@export var knockback := 500.0;

func _dealDamage(body: Node2D) -> void:
	if (body.has_method("takeDamage")):
		var knockbackDir;
		
		knockbackDir = body.position - position;
		knockbackDir = knockbackDir.normalized();
		
		body.takeDamage(knockbackDir * knockback, damage);
