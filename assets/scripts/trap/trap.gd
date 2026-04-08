extends Node2D
class_name Trap

@export var dmdOnly := false;
@export var damage := 1;
@export var knockback := 225.0;

func _ready() -> void:
	if (dmdOnly && GameManager.getDifficulty() != GameManager.DIFFICULTY.DMD):
		queue_free();

func _dealDamage(body: Node2D, knockbackPos: Vector2) -> bool:
	if (body.has_method("takeDamage")):
		var knockbackDir;
		
		knockbackDir = body.global_position - knockbackPos;
		knockbackDir = knockbackDir.normalized();
		
		body.takeDamage(knockbackDir * knockback, damage);
		
		return true;
	
	return false;
