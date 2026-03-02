extends Area2D

const BLOOD_DROP := preload("res://assets/scenes/Effects/blood_drop.tscn");

@export var lifetime := 1.0;
## Time (seconds) before lifetime is over that the blood will fade away.
@export var alphaFadeTime := 0.1;
@export var velocity := Vector2(0.0, 0.0);
## Velocity in relation to this bloods velocity length that blood drops get
#@export var bloodDropVelocityScale := 0.25;
@export var slowDownLerp := Vector2(300.0, 250.0);
@export var gravityForce := 800.0;
## Downwards velocity once blood settings on a tile
@export var gravityVelocityTile := 4.0;

var onTile = false;

func setVelocity(_velocity: Vector2) -> void:
	velocity = _velocity;

func _process(delta: float) -> void:
	lifetime -= delta;
	
	if (lifetime <= 0.0):
		queue_free();
		return;
	elif (lifetime <= alphaFadeTime):
		%Sprite2D.self_modulate = Color(1, 1, 1, lifetime / alphaFadeTime);
		return;

#func placeBlood() -> void:
	#if (_onTile()):
		#GameManager.drawBlood(global_position);
	
	#var bloodDrop;
	#bloodDrop = BLOOD_DROP.instantiate();
	#bloodDrop.global_position = global_position;
	#bloodDrop.setVelocity(velocity.length() * bloodDropVelocityScale);
	#GameManager.addEffect(bloodDrop);

func _physics_process(delta: float) -> void:
	position += velocity * delta
	
	if (!_onTile()):
		velocity.y += gravityForce * delta;
		
		# Free when we get off a tile
		if (onTile):
			queue_free();
	else:
		onTile = true;
		
		# Start slowing down now that we are on a tile
		velocity.x = move_toward(velocity.x, 0.0, slowDownLerp.x * delta);
		velocity.y = move_toward(velocity.y, gravityVelocityTile, slowDownLerp.y * delta);
		
		GameManager.drawBlood(global_position);
	
func _onTile() -> bool:
	if (get_overlapping_bodies().size() > 0):
		var sizeX;
		var sizeY;
		var points = [];
		
		sizeX = %CollisionShape2D.shape.size.x / 2.0;
		sizeY = %CollisionShape2D.shape.size.y / 2.0;
		
		points.push_back(Vector2(global_position.x - sizeX, global_position.y - sizeY));
		points.push_back(Vector2(global_position.x + sizeX, global_position.y + sizeY));
		points.push_back(Vector2(global_position.x + sizeX, global_position.y - sizeY));
		points.push_back(Vector2(global_position.x - sizeX, global_position.y + sizeY));
		
		for point in points:
			if (!_pointHitsTile(point)):
				return false;
		
		return true;
		
	return false;
	
func _pointHitsTile(point: Vector2) -> bool:
	var space = get_world_2d().direct_space_state;

	var query = PhysicsPointQueryParameters2D.new();
	query.position = point
	query.collision_mask = 0b100000000;

	var result = space.intersect_point(query, 1)

	return result.size() > 0
