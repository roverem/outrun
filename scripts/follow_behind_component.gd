class_name FollowBehindComponent extends Node

@export var target:Node3D 		# Object to follow
@export var body:Node3D 		# Object to move. Owner

@export var amplitude: float = 0.2  # distancia máxima hacia adelante/atrás
@export var speed: float = 0.3      # velocidad de oscilación
@export var align_speed: float = 0.5   # how fast the camera re-centers

var base_position: Vector3
var base_rotation: Vector3

func _ready() -> void:
	base_position = body.position
	base_rotation = body.rotation_degrees
	
func tick(delta:float)->void:
	if body == null or target == null:
		print("[ERROR] No target or body assigned.")
		return
		
	body.position.y = base_position.y + sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude
	
	body.position.x = lerp(body.position.x, target.position.x, delta * align_speed)
