extends Trap

@export var swingLeft := false;
@export var sawSpeed := 1.0;

func _ready() -> void:
	%AnimationPlayer.speed_scale = sawSpeed;
	
	if (swingLeft):
		%AnimationPlayer.speed_scale *= -1.0;

func _on_saw_body_entered(body: Node2D) -> void:
	_dealDamage(body);
