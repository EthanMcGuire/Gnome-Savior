extends Node2D

func _ready() -> void:
	var minutes: int;
	var seconds: float;

	seconds = GameManager.getSpeedrunTime() / 1000.0;
	minutes = int(seconds) / 60;
	seconds = fmod(seconds, 60.0);
	
	%LabelTime.text = "%d:%02d" % [minutes, floor(seconds)];
	%LabelDecimal.text = ".%02d" % [fmod(seconds, 1.0) * 100];

func _on_button_quit_pressed() -> void:
	get_tree().quit();
