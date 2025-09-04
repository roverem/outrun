extends Node3D  # or CharacterBody3D if you want floor detection later

@export var steer_speed: float = 3.5
@export var max_steer: float = 6.5
@export var tilt_angle: float = 0.0
@export var tilt_speed: float = 5.0
@export var yaw_angle: float = 25.0
@export var pitch_angle: float = 10.0


var base_position: Vector3

func _ready():
	base_position = global_position

func _process(delta):
	var input_dir := 0.0
	if Input.is_action_pressed("ui_right"):
		input_dir -= 1
	if Input.is_action_pressed("ui_left"):
		input_dir += 1
	
	# Move left/right
	global_position.x = clamp(global_position.x + input_dir * steer_speed * delta, -max_steer, max_steer)
	global_position.z = base_position.z


	# Tilts
	var target_roll = input_dir * tilt_angle           # Z axis lean
	var target_yaw = input_dir * yaw_angle             # Y axis slight twist
	var target_pitch = -abs(input_dir) * pitch_angle   # X axis dip

	rotation_degrees.z = lerp(rotation_degrees.z, target_roll, delta * tilt_speed)
	rotation_degrees.y = lerp(rotation_degrees.y, target_yaw, delta * (tilt_speed * 0.5))
	rotation_degrees.x = lerp(rotation_degrees.x, target_pitch, delta * (tilt_speed * 0.5))
