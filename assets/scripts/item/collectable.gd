@abstract 
class_name Collectable
extends Area2D

@abstract func _collect() -> void;

## Number of the item to give.
@export var itemName := "Item";
@export var count := 1;

var collected = false;

func _getCollected(body: Node2D) -> void:
	if (body is not PlayerController): return;
	if (collected): return;
	
	print("Player collected " + itemName + ".");
	
	collected = true;
	_collect();
