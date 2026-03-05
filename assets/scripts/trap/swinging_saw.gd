extends Trap

@export var swingLeft := false;
@export var speed := 1.0;

func _ready() -> void:
	%AnimationPlayer.speed_scale = speed;
	
	if (swingLeft):
		%AnimationPlayer.speed_scale *= -1.0;

func _on_saw_body_entered(body: Node2D) -> void:
	_dealDamage(body, %Saw.global_position);
