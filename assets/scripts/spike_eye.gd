extends Area2D
class_name SpikeEye

@export var knockback := 500.0;

func _on_body_entered(body: Node2D) -> void:
	if (body.has_method("takeDamage")):
		var knockbackDir;
		
		knockbackDir = body.position - position;
		knockbackDir = knockbackDir.normalized();
		
		body.takeDamage(knockbackDir * knockback);
