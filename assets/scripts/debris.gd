extends RigidBody2D
class_name Debris

@export var RANDOM_DEGREES := 60.0;

func setTexture(texture: Texture2D, flipH: bool, scale: float) -> void:
	%Sprite2D.texture = texture;
	%Sprite2D.flip_h = flipH;
	%Sprite2D.scale = Vector2(scale, scale);

func setRegion(xOffset: float, yOffset: float, width: float, height: float) -> void:
	%Sprite2D.region_rect = Rect2(xOffset, yOffset, width, height);
	
func applyKnockback(knockback: Vector2) -> void:
	var radians;
	
	radians = deg_to_rad(RANDOM_DEGREES);
	
	apply_impulse(knockback.rotated(randf_range(-radians, radians)));

#enum GRAVITY {
	#DOWN,
	#UP,
	#LEFT,
	#RIGHT
#};
#
#var gravity := GRAVITY.DOWN;
#
#func setGravity(_gravity: GRAVITY):
	#gravity = _gravity;
#
#func _ready() -> void:
	#gravity_scale = 0;
	#
#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#apply_force(_getGravityVector())
#
#func _getGravityVector() -> Vector2:
	#var gravVector = get_gravity();
	#
	#match (gravity):
		#GRAVITY.UP:
			#gravVector.y *= -1.0;
		#GRAVITY.LEFT:
			#gravVector.x = gravVector.y * -1.0;
			#gravVector.y = 0.0;
		#GRAVITY.RIGHT:
			#gravVector.x = gravVector.y;
			#gravVector.y = 0.0;
	#
	#return gravVector;
