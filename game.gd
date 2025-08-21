extends Node3D

@onready var camera_3d: Camera3D = $"sedan-sports"/Camera3D
@export var amplitude: float = 0.2  # distancia máxima hacia adelante/atrás
@export var speed: float = 0.3      # velocidad de oscilación
@onready var directional_light_3d: SpotLight3D = $DirectionalLight3D
@export_range(-220, -180) var x_min_cam_angle
@export_range(-180, -100) var x_max_cam_angle
@export_range(-45, 0) var y_min_cam_angle
@export_range(0, 90) var y_max_cam_angle
@export_range(0.2, 4) var mouse_sensitivity:float

@onready var debug_text:RichTextLabel = %DebugText

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
	debug_text.clear()
	debug_text.add_text( "center " + str(center) )
	
	var x_dist = center.x - mouse_pos.x;
	var y_dist = center.y - mouse_pos.y;
	
	var horizontal_rate = x_dist / center.x;
	var vertical_rate = y_dist / center.y;
	
	debug_text.add_text("\nRATE horizontal: " + str(horizontal_rate) + " vertical: " + str(vertical_rate) )
	
	debug_text.add_text("\n base rotation x: " + str( rad_to_deg(base_rotation.x) ) + " y: " + str( rad_to_deg(base_rotation.y) ) )
	
	camera_3d.rotation.x = clamp(base_rotation.x + vertical_rate * mouse_sensitivity, deg_to_rad( y_min_cam_angle), deg_to_rad( y_max_cam_angle) )
	camera_3d.rotation.y = clamp(base_rotation.y + horizontal_rate * mouse_sensitivity, deg_to_rad(x_min_cam_angle), deg_to_rad(x_max_cam_angle))
	
	debug_text.add_text("\n camera rotation vertical" + str( rad_to_deg(camera_3d.rotation.x)) + " horizontal: " + str(rad_to_deg(camera_3d.rotation.y)) )
	debug_text.add_text("\n min_angle x " + str( x_min_cam_angle) + " : " + str(  x_max_cam_angle ) )
	debug_text.add_text("\n min_angle y " + str( y_min_cam_angle) + " : " + str( y_max_cam_angle  ) )
	
	#print(camera_3d.rotation)
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
		
		
