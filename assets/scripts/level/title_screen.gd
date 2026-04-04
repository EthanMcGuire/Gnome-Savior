extends Node2D

func _start() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/Levels/intro.tscn");

func _on_button_play_pressed() -> void:
	%Buttons1.visible = false;
	%Buttons2.visible = true;
	
func _on_button_quit_pressed() -> void:
	get_tree().quit();

func _on_button_easy_pressed() -> void:
	GameManager.setDifficulty(GameManager.DIFFICULTY.EASY);
	_start();

func _on_button_hard_pressed() -> void:
	GameManager.setDifficulty(GameManager.DIFFICULTY.HARD);
	_start();

func _on_button_super_hard_pressed() -> void:
	GameManager.setDifficulty(GameManager.DIFFICULTY.SUPER_HARD);
	_start();

func _on_button_back_pressed() -> void:
	%Buttons1.visible = true;
	%Buttons2.visible = false;

func _on_music_slider_drag_ended(value_changed: bool) -> void:
	if (value_changed):
		GameManager.setMusicVolume(linear_to_db(%MusicSlider.value));

func _on_sound_slider_drag_ended(value_changed: bool) -> void:
	if (value_changed):
		GameManager.setSoundVolume(linear_to_db(%SoundSlider.value));
		
func _on_funny_toggle_toggled(toggled_on: bool) -> void:
	var bus_index;
	var effect_index;
	
	bus_index = AudioServer.get_bus_index("Master");
	AudioServer.set_bus_effect_enabled(bus_index, 0, true);
	
	%FunnyToggle.disabled = true;
	
func _on_button_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/Levels/credits.tscn");
