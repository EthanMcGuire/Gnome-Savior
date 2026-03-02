extends Control
class_name SignText

@onready var signBoard = %SignBoard;
@export var lerpSpeed := 0.3;

var isHidden := true;
var centerLocationY: float;
var hiddenLocationY: float;

func _ready() -> void:
	centerLocationY = signBoard.position.y;
	hiddenLocationY = centerLocationY + 96.0;
	
	signBoard.position.y = hiddenLocationY;

func _physics_process(delta: float) -> void:
	if (isHidden):
		signBoard.position.y = lerp(signBoard.position.y, hiddenLocationY, lerpSpeed);
	else:
		signBoard.position.y = lerp(signBoard.position.y, centerLocationY, lerpSpeed);
		
func setText(text: String):
	%Label.text = text;
	
func showSign():
	isHidden = false;

func hideSign():
	isHidden = true;
