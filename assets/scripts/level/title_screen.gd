extends Node2D

func _ready() -> void:
	%ButtonPlay.grab_focus();
	
	if (GameManager.getFunnyModeEnabled()):
		%FunnyToggle.disabled = true;
		%FunnyToggle.button_pressed = true;
		
	if (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN):
		%FullscreenToggle.button_pressed = true;
		
	%MusicSlider.value = db_to_linear(GameManager.getMusicVolume());
	%SoundSlider.value = db_to_linear(GameManager.getSoundVolume());

func _start() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/Levels/intro.tscn");

func _on_button_play_pressed() -> void:
	%Buttons1.visible = false;
	%Buttons2.visible = true;
	%Sound.visible = false;
	%FunnyToggle.visible = false;
	%FullscreenToggle.visible = false;
	%ButtonCredits.visible = false;
	%ButtonEasy.grab_focus();
	
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
	%Sound.visible = true;
	%FunnyToggle.visible = true;
	%FullscreenToggle.visible = true;
	%ButtonCredits.visible = true;
	%ButtonPlay.grab_focus();
		
func _on_funny_toggle_toggled(toggled_on: bool) -> void:
	GameManager.enableFunnyMode();
	%FunnyToggle.disabled = true;
	
func _on_fullscreen_toggle_toggled(toggled_on: bool) -> void:
	if (toggled_on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
func _on_button_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/Levels/credits.tscn");

func _on_music_slider_value_changed(value: float) -> void:
	GameManager.setMusicVolume(linear_to_db(%MusicSlider.value));

func _on_sound_slider_value_changed(value: float) -> void:
	GameManager.setSoundVolume(linear_to_db(%SoundSlider.value));
