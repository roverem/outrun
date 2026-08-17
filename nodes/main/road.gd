extends Node3D

var starting_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_position = global_position.z


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(global_position.z)
	global_position.z += Global.PLAYER_SPEED * delta
	if global_position.z > 20:
		global_position.z = starting_position 
