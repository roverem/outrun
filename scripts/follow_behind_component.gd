class_name FollowBehindComponent extends Node

@export var target:Node3D 		# Object to follow
@export var body:Node3D 		# Object to move. Owner

@export var amplitude: float = 0.2  # distancia máxima hacia adelante/atrás
@export var speed: float = 0.3      # velocidad de oscilación
@export var align_speed: float = 0.5   # how fast the camera re-centers

@export var max_tilt: float = 8
@export var min_tilt: float = -8

var base_position: Vector3
var base_rotation: Vector3

func _ready() -> void:
	base_position = body.position
	base_rotation = body.rotation_degrees
	
func tick(delta:float)->void:
	if body == null or target == null:
		print("[ERROR] No target or body assigned.")
		return
		
	#reposition
	body.position.y = base_position.y + sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude
	body.position.x = lerp(body.position.x, target.position.x, delta * align_speed)
	
	#tilt balloon
	var distance_to_target = body.position - target.position
	var tilt = remap( distance_to_target.x, -6, 6, min_tilt, max_tilt)
	body.rotation_degrees.z = tilt
