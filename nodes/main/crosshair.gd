extends TextureRect

func _process(_delta):
	global_position = get_viewport().get_visible_rect().size / 2 - (size * 0.5)
