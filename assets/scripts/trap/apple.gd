extends Trap

const APPLE_SPLAT = preload("res://assets/scenes/Entities/Traps/apple_splat.tscn");

@export var isFake := false;
@export var gravity := 150.0;
@export var rotateSpeed := 12;

var falling := false;
var rotateDir := 1.0;

func _ready() -> void:
	super();
	%Area2D.set_collision_mask_value(1, false);
	%Sprite2D.rotation = randf_range(-0.9, 0.9);
	
	if (randf() <= 0.5):
		rotateDir = -1.0;

func _physics_process(delta: float) -> void:
	if (isFake): return;
	
	if (falling):
		position.y += gravity * delta;
		%Sprite2D.rotation += rotateDir * rotateSpeed * delta;
	
	if (%RayCast2D.is_colliding()):
		falling = true;
		%Area2D.set_collision_mask_value(1, true);

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (!falling): return;
	
	var splat = APPLE_SPLAT.instantiate();
	splat.global_position = global_position;
	get_parent().add_child(splat);
	
	_dealDamage(body, %Area2D.global_position);
	
	queue_free();
