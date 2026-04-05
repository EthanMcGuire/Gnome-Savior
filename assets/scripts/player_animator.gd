extends Node2D
class_name PlayerAnimator

@export var animationPlayer: AnimationPlayer;
@export var sprite: Sprite2D;

func set_sprite_h_flip(flip: bool) -> void:
	sprite.flip_h = flip;

func get_sprite_h_flip() -> bool:
	return sprite.flip_h;

#region Animations
	
func play_animation(name: String) -> void:
	animationPlayer.play(name);

#endregion Animations
