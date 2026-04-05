extends Node2D

const SPEED := 20;

func _ready() -> void:
	%ButtonBack.grab_focus();
	%LabelCredits.position.y += 270;

func _process(delta: float) -> void:
	# Scroll the credits
	%LabelCredits.position.y -= delta * SPEED;

func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/Levels/title_screen.tscn");
