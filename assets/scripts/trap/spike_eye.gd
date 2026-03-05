extends Trap

enum MOVE_DIR {
	MOVE_DIR_NONE,
	MOVE_DIR_LEFT,
	MOVE_DIR_RIGHT,
	MOVE_DIR_DOWN,
	MOVE_DIR_UP
}

@export var moveDir := MOVE_DIR.MOVE_DIR_NONE;

func _ready() -> void:
	match moveDir:
		MOVE_DIR.MOVE_DIR_NONE:
			%AnimationPlayer.play("idle");
		MOVE_DIR.MOVE_DIR_LEFT:
			%AnimationPlayer.play("move_left");
		MOVE_DIR.MOVE_DIR_RIGHT:
			%AnimationPlayer.play("move_right");
		MOVE_DIR.MOVE_DIR_DOWN:
			%AnimationPlayer.play("move_down");
		MOVE_DIR.MOVE_DIR_UP:
			%AnimationPlayer.play("move_up");

func _on_area_2d_body_entered(body: Node2D) -> void:
	_dealDamage(body);
