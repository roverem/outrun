extends Sprite3D

var mat : StandardMaterial3D

var starting_scale
var starting_transparency

func _ready() -> void:
	starting_transparency = transparency
	starting_scale = scale
	

func dissapear():
	scale = starting_scale
	transparency = starting_transparency
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0,0.3,1), 0.3)
	tween.tween_property(self, "transparency", 0.0, 0.15)
	
	
	#traer el delay aca tmb
	
