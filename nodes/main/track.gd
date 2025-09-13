class_name Track
extends Node3D

var _next_z := 50.0           # dónde colocar la próxima pieza (en +Z)



@onready var lanes: Array[Marker3D] = [$lane1, $lane2, $lane3]


func _process(delta: float) -> void:
	for child in get_children():
		if child.is_in_group("NoScroll"):			
			continue
		child.translate(Vector3(0, 0, -Global.PLAYER_SPEED * delta))
	
func spawn(scene):
	var lane = lanes.pick_random()
	scene.position = lane.position
	add_child(scene)
	
