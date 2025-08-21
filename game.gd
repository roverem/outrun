extends Node3D

@onready var camera_3d: Camera3D = $"sedan-sports"/Camera3D
@export var amplitude: float = 0.2  # distancia máxima hacia adelante/atrás
@export var speed: float = 0.3      # velocidad de oscilación
@onready var directional_light_3d: SpotLight3D = $DirectionalLight3D

var angle_range:float = 15.0
var base_position: Vector3
var base_rotation: Vector3

func _ready() -> void:
	base_position = camera_3d.position  # guarda la posición inicial
	base_rotation = camera_3d.rotation
	
func _process(delta: float) -> void:
	# Movimiento oscilante en el eje Z
	camera_3d.position.y = base_position.y + sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	
	var center = viewport_size / 2
	
	var x_dist = center.x - mouse_pos.x;
	var y_dist = center.y - mouse_pos.y;
	
	var camera_x_rate = x_dist / center.x;
	var camera_y_rate = y_dist / center.y;
	
	print(camera_x_rate, camera_y_rate)
	
	if mouse_pos.x > center.x:
		print("Mouse a la DERECHA de la pantalla", x_dist , y_dist)
	else:
		print("Mouse a la IZQUIERDA de la pantalla", x_dist, y_dist)
	camera_3d.rotation.x = clamp(base_rotation.x + camera_y_rate * 0.4, -1, 0.2)
	camera_3d.rotation.y = clamp(base_rotation.y + camera_x_rate * 0.4, -3.6, -3)
	
	print(camera_3d.rotation)
	#var mouse_pos = event.position
	var from = camera_3d.project_ray_origin(mouse_pos)
	var to = from + camera_3d.project_ray_normal(mouse_pos) * 1000.0
	directional_light_3d.look_at(to)
	
	

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = event.position
		var from = camera_3d.project_ray_origin(mouse_pos)
		var to = from + camera_3d.project_ray_normal(mouse_pos) * 1000.0
		print("Ray from:", from, "to:", to);
		
		
