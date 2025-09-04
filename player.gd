extends Node3D  # or CharacterBody3D if you want floor detection later

@export var steer_speed: float = 10.0
@export var max_steer: float = 6.5
@export var tilt_angle: float = 12.0
@export var tilt_speed: float = 5.0    # how fast tilt reacts

var base_position: Vector3

func _ready():
	base_position = global_position

func _process(delta):
	var input_dir := 0.0
	if Input.is_action_pressed("ui_right"):
		input_dir -= 1
	if Input.is_action_pressed("ui_left"):
		input_dir += 1

	var tilt_target = input_dir * tilt_angle
	
	global_position.x = clamp(global_position.x + input_dir * steer_speed * delta, -max_steer, max_steer)
	global_position.z = base_position.z  # keep car fixed in depth
	#rotation_degrees.z = lerp(rotation_degrees.z, tilt_target, delta * tilt_speed)
	rotation_degrees.x = lerp(rotation_degrees.x, -10.0 * abs(input_dir), delta * (tilt_speed * 0.5) )
	rotation_degrees.z = lerp(rotation_degrees.z, -10.0 * input_dir, delta * (tilt_speed * 0.5) )
	rotation_degrees.y = lerp(rotation_degrees.y, 30.0 * input_dir, delta * (tilt_speed * 0.5) )
