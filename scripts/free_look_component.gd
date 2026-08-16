class_name FreeLookComponent extends Node

@export var camera : Camera3D 

@export_range(-360, 360) var horizontal_min_angle = -260
@export_range(-360, 360) var horizontal_max_angle = -110
@export_range(-360, 360) var vertical_min_angle = -80
@export_range(-360, 360) var vertical_max_angle = 20
@export_range(0.2, 2) var mouse_sensitivity:float = 0.2

var yaw:float
var pitch:float

func _process(_delta: float) -> void:
	camera.rotation_degrees

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		
		pitch = clamp(pitch, vertical_min_angle, vertical_max_angle)
		yaw = clamp(yaw, horizontal_min_angle, horizontal_max_angle)
		
		camera.rotation_degrees.y = yaw
		camera.rotation_degrees.x = pitch
