extends Node2D

@export var dmdOnly := false;

func _ready() -> void:
	if (dmdOnly && GameManager.getDifficulty() != GameManager.DIFFICULTY.DMD):
		queue_free();
