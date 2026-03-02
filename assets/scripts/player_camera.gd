extends Camera2D
class_name PlayerCamera

func setLimits(left: int, top: int, right: int, bottom: int):
	limit_left = left - offset.x;
	limit_top = top - offset.y;
	limit_right = right - offset.x;
	limit_bottom = bottom - offset.y;
