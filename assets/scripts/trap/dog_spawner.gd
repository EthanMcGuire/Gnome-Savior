extends Area2D

const DOG_SCENE := preload("res://assets/scenes/Entities/Traps/dog.tscn");

@export var spawnPoint := Vector2();

func _ready() -> void:
	%ColorRect.visible = false;

func _spawnDog() -> void:
	var dog = DOG_SCENE.instantiate();
	dog.global_position = spawnPoint;
	
	get_parent().add_child(dog);

func _on_body_entered(body: Node2D) -> void:
	if (body is PlayerController):
		call_deferred("_spawnDog");
		queue_free();
