extends Area2D
class_name Checkpoint

const GNOME_SCENE := preload("res://assets/scenes/Entities/gnome.tscn");

@export var checkpointName := "default_name";
### Forces the gnome to walk right when saved
@export var forceRight := false;

var isOpen = false;
var gnome: Gnome = null;

func _ready() -> void:
	var disabled = false;
	
	# Disable the checkpoint on super hard mode
	if (GameManager.getDifficulty() == GameManager.DIFFICULTY.SUPER_HARD):
		isOpen = true;
		disabled = true;
	elif (GameManager.checkCheckpointCollected(checkpointName)):
		isOpen = true;
		
	# Spawn a gnome if this checkpoint hasn't been hit
	if (!isOpen):
		# Spawn a gnome
		gnome = GNOME_SCENE.instantiate();
		gnome.global_position = %SpawnPoint.global_position;
		GameManager.addGnome(gnome);
	else:
		_showOpenSprite();
	
	# Move player to the checkpoint
	if (!disabled && GameManager.getCurrentCheckpointName() == checkpointName):
		GameManager.setPlayerPosition(%SpawnPoint.global_position);

func _open() -> void:
	if (isOpen): return;
	
	isOpen = true;
	
	_showOpenSprite();
	%AudioStreamPlayer2D.play();
	
	# Free the gnome!!
	gnome.freeGnome(forceRight);
	gnome = null;
	
	GameManager.checkpointHit(checkpointName);
	GameManager.createStarParticles(%SpawnPoint.global_position);

func _showOpenSprite() -> void:
	%SpriteClosed.visible = false;
	%SpriteOpen.visible = true;

func _on_body_entered(body: Node2D) -> void:
	if (body is PlayerController):
		_open();
