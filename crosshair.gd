extends TextureRect

func _process(_delta):
	global_position = get_viewport().get_mouse_position() - (size * 0.5)
