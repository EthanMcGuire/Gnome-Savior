extends Trap

@export var swingLeft := false;
@export var speed := 1.0;
@export var startDelay := 0.0;

func _ready() -> void:
	%AnimationPlayer.speed_scale = speed;
	
	if (swingLeft):
		%AnimationPlayer.speed_scale *= -1.0;
		
	if (startDelay <= 0.0):
		_start();
	else:
		%StartDelayTimer.start(startDelay);

func _start() -> void:
	%AnimationPlayer.play("swing");

func _on_saw_body_entered(body: Node2D) -> void:
	_dealDamage(body, %Saw.global_position);

func _on_start_delay_timer_timeout() -> void:
	_start();
