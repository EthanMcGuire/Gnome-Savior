extends Area2D
class_name Sign

@export var text := "Hello world.";
@export var textController := "";
@export var textDmd := "";
@export var textDmdController := "";

var usingGamepad := false;
var isVisible = false;

func _ready() -> void:
	usingGamepad = GameManager.getUsingGamepad();

func _process(delta: float) -> void:
	var new = GameManager.getUsingGamepad();
	
	if (usingGamepad != new):
		usingGamepad = new;
		if (isVisible): _showText();

func _showText() -> void:
	var textToShow = "";
	
	if (GameManager.getDifficulty() == GameManager.DIFFICULTY.DMD && textDmd != ""):
		if (!usingGamepad || textDmdController == ""):
			textToShow = textDmd;
		else:
			textToShow = textDmdController;
	else:
		if (!usingGamepad || textController == ""):
			textToShow = text;
		else:
			textToShow = textController;
				
	GameManager.showSign(textToShow);

func _on_body_entered(body: Node2D) -> void:
	if (body is PlayerController):
		_showText();
		isVisible = true;

func _on_body_exited(body: Node2D) -> void:
	if (body is PlayerController):
		GameManager.hideSign();
		isVisible = false;
