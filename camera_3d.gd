extends Camera3D

@export var car: Node3D
@export var align_speed: float = 2.0   # how fast the camera recenters

var base_position: Vector3

func _ready():
	base_position = global_position

func _process(delta: float) -> void:
	if car == null:
		return

	# Target is always behind the car (aligned in X)
	var target_pos = base_position
	target_pos.x = car.global_position.x

	# Smoothly move toward target position
	global_position.x = lerp(global_position.x, target_pos.x, delta * align_speed)
