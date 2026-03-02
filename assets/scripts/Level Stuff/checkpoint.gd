extends Area2D
class_name Checkpoint

const GNOME_SCENE := preload("res://assets/scenes/Entities/gnome.tscn");

@export var checkpointName := "default_name";

var isOpen = false;
var gnome: Gnome = null;

func _ready() -> void:
	# Spawn a gnome if this checkpoint hasn't been hit
	if (GameManager.checkCheckpointCollected(checkpointName)):
		isOpen = true;
		_showOpenSprite();
	else:
		# Spawn a gnome
		gnome = GNOME_SCENE.instantiate();
		gnome.global_position = %SpawnPoint.global_position;
		GameManager.addGnome(gnome);
	
	# Move player to the checkpoint
	if (GameManager.getCurrentCheckpointName() == checkpointName):
		GameManager.setPlayerPosition(%SpawnPoint.global_position);

func _open() -> void:
	if (isOpen): return;
	
	isOpen = true;
	
	_showOpenSprite();
	%AudioStreamPlayer2D.play();
	
	# Free the gnome!!
	gnome.freeGnome();
	gnome = null;
	
	GameManager.checkpointHit(checkpointName);

func _showOpenSprite() -> void:
	%SpriteClosed.visible = false;
	%SpriteOpen.visible = true;

func _on_body_entered(body: Node2D) -> void:
	if (body is PlayerController):
		_open();
