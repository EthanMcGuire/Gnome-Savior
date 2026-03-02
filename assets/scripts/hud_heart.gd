extends TextureRect
class_name HudHeart

func setFull():
	texture.region =  Rect2(0.0, 8.0, 8.0, 8.0);
	
func setEmpty():
	texture.region =  Rect2(8.0, 8.0, 8.0, 8.0);
