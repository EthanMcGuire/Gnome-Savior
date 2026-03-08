extends Node2D

@export var scrollSpeed := 20.0;
@export var musicVolumeChange := 10.0;
@export var gnomeMoveSpeed := 15.0;

var startingTransition := false;

func _process(delta: float) -> void:
	%IntroText.position.y -= scrollSpeed * delta;
	
	if (startingTransition):
		%Gnome.position.x = max(%Gnome.position.x - gnomeMoveSpeed * delta, 0.0);
		%MusicPlayer.volume_db -= musicVolumeChange * delta;
		
	# Skip intro
	if (Input.is_action_just_pressed("pause")):
		_start();

func _on_transition_timer_timeout() -> void:
	startingTransition = true;
	%StartTimer.start();

func _on_start_timer_timeout() -> void:
	_start();
	
func _start():
	get_tree().change_scene_to_file("res://assets/scenes/Levels/level_base.tscn");
