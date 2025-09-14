class_name Track
extends Node3D

var _next_z := 50.0           # dónde colocar la próxima pieza (en +Z)

@onready var forward_lanes: Array[Marker3D] = [$lane1, $lane2, $lane3]
@onready var backward_lanes: Array[Marker3D] = [$lane4, $lane5]
@onready var velocities:Array[float] = [6, 6, 5, 5, 25, 15.5, 17, 18, 10]

func _process(delta: float) -> void:
	for child in get_children():
		if child.is_in_group("NoScroll"):
			continue
		child.translate(Vector3(0, 0, -Global.PLAYER_SPEED * delta))
		if child.has_meta("velocity"):
			child.translate(Vector3(0, 0, child.get_meta("velocity") * delta))
	
func spawn(scene):
	
	if not scene.has_meta("velocity"):
		scene.set_meta("velocity", velocities.pick_random())
		
	
	Global.DEBUG_TEXT.add_text( str(scene) + " " + str(scene.get_meta("velocity")) + "\n" )
	if ( Global.DEBUG_TEXT.get_line_count() > 20):
		Global.DEBUG_TEXT.clear()
	
	
	var forward:bool = scene.get_meta("velocity") < Global.PLAYER_SPEED
	
	var lane
	if forward:
		lane = forward_lanes.pick_random()
	else:
		lane = backward_lanes.pick_random()
		
	scene.position = lane.position
	
	add_child(scene)
