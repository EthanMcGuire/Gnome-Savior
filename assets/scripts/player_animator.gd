extends Node2D
class_name PlayerAnimator

@export var animationPlayer: AnimationPlayer;
@export var sprite: Sprite2D;

func set_sprite_h_flip(flip: bool) -> void:
	sprite.flip_h = flip;

#region Animations

func play_animation_idle() -> void:
	animationPlayer.play("idle");

func play_animation_moving() -> void:
	animationPlayer.play("walk");
	
func play_animation_jump() -> void:
	animationPlayer.play("jump");
	
func play_animation_falling() -> void:
	animationPlayer.play("fall");

#endregion Animations
