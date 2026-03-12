extends Control
class_name SpeedrunTimer

func _ready() -> void:
	setTime(0);

func setTime(ms: int):
	var minutes: int;
	var seconds: float;

	seconds = ms / 1000.0;
	minutes = int(seconds) / 60;
	seconds = fmod(seconds, 60.0);
	
	%LabelTime.text = "%d:%02d" % [minutes, floor(seconds)];
	%LabelDecimal.text = ".%02d" % [fmod(seconds, 1.0) * 100];
