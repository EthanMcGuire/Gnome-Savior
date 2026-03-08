@tool
extends Node2D

const BULLET := preload("res://assets/scenes/Entities/Traps/bullet.tscn");

@export var range := 160.0:
	set(value):
		range = value;
		%RayCast2D.target_position = Vector2(range, 0.0);
		
@export var shootSpeed := 1.0;

func _ready() -> void:
	%AnimationPlayer.speed_scale = shootSpeed;

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return;	
		
	var collidingWithPlayer := false;
	
	# Check for player to shoot
	if (%RayCast2D.is_colliding()):
		var collider = %RayCast2D.get_collider();
		
		if (collider is PlayerController):
			collidingWithPlayer = true;

	if (collidingWithPlayer && !%AnimationPlayer.is_playing()):
		_shoot();
		
func _shoot():
	var bullet;
	
	bullet = BULLET.instantiate();
	bullet.global_position = %BulletSpawn.global_position;
	bullet.rotation = rotation;
	GameManager.addProjectile(bullet);
	
	%AnimationPlayer.play("shoot");
