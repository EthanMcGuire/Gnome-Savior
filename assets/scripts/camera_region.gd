@tool
extends Area2D
class_name CameraRegion

@export var firstRegion := false;

@export_range(16.0, 3200.0, 0.25) var regionSizeX := 16.0:
	set(value):
		regionSizeX = value;
		snappedRegionSizeX = _snapValue(regionSizeX);
		_updateCollisionShape();
		
@export_range(16.0, 3200.0, 0.25) var regionSizeY := 16.0:
	set(value):
		regionSizeY = value;
		snappedRegionSizeY = _snapValue(regionSizeY);
		_updateCollisionShape();

var snappedRegionSizeX := 16.0;
var snappedRegionSizeY := 16.0;

func _ready() -> void:
	if Engine.is_editor_hint():
		return;	
		
	_updateCollisionShape();
	
	if (firstRegion):
		_setCameraLimits();
		GameManager.moveCameraToGoal();
	
func _snapValue(value: float) -> float:
	return round(value / 16.0) * 16.0;
	
func _updateCollisionShape() -> void:
	var collision := get_node("CollisionShape2D");
	var shape := collision.shape as RectangleShape2D;
	shape.size = Vector2(snappedRegionSizeX, snappedRegionSizeY);
	collision.position = Vector2(snappedRegionSizeX * 0.5, snappedRegionSizeY * 0.5);
	
func _setCameraLimits() -> void:
	if Engine.is_editor_hint():
		return;	
	
	var collision := get_node("CollisionShape2D");
	var shape := collision.shape as RectangleShape2D;
	var left;
	var top;
	
	left = position.x;
	top = position.y;
	
	GameManager.setCameraLimits(left, top, left + shape.size.x, top + shape.size.y);

func _on_body_entered(body: Node2D) -> void:
	if Engine.is_editor_hint():
		return;
		
	if (body is PlayerController):
		_setCameraLimits();
