extends Node2D

const DIFFICULTY_NAME = {
	GameManager.DIFFICULTY.EASY: "Easy",
	GameManager.DIFFICULTY.HARD: "Hard",
	GameManager.DIFFICULTY.SUPER_HARD: "Super Hard",
	GameManager.DIFFICULTY.DMD: "DMD"
};

const DIFFICULTY_COLOR = {
	GameManager.DIFFICULTY.EASY: Color(0.188, 0.855, 1.0, 1.0),
	GameManager.DIFFICULTY.HARD: Color(1, 0, 0, 1),
	GameManager.DIFFICULTY.SUPER_HARD: Color(1, 0.2, 0),
	GameManager.DIFFICULTY.DMD: Color(0.357, 0.0, 0.843, 1.0)	
};

func _ready() -> void:
	var minutes: int;
	var seconds: float;

	seconds = GameManager.getSpeedrunTime() / 1000.0;
	minutes = int(seconds) / 60;
	seconds = fmod(seconds, 60.0);
	
	%LabelTime.text = "%d:%02d" % [minutes, floor(seconds)];
	%LabelDecimal.text = ".%02d" % [fmod(seconds, 1.0) * 100];
	
	%Difficulty.text = "Difficulty: " + DIFFICULTY_NAME[GameManager.getDifficulty()];
	%Difficulty.modulate = DIFFICULTY_COLOR[GameManager.getDifficulty()];

func _on_button_quit_pressed() -> void:
	get_tree().quit();
