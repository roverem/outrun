extends Camera3D

@export var amplitude: float = 0.2  # distancia máxima hacia adelante/atrás
@export var speed: float = 0.3      # velocidad de oscilación
@export_range(-360, 360) var horizontal_min_angle
@export_range(-360, 360) var horizontal_max_angle
@export_range(-360, 360) var vertical_min_angle
@export_range(-360, 360) var vertical_max_angle
@export_range(0.2, 200) var mouse_sensitivity:float
@onready var directional_light_3d: SpotLight3D = $DirectionalLight3D

@export var car: Node3D
@export var align_speed: float = 2.0   # how fast the camera recenters

var base_position: Vector3
var base_rotation: Vector3

var yaw:float = 0.0
var pitch:float = 0.0

func _ready():
	base_position = global_position
	base_rotation = global_rotation_degrees
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if car == null:
		return
		
	global_position.y = base_position.y + sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude

	# Target is always behind the car (aligned in X)
	var target_pos = base_position
	target_pos.x = car.global_position.x

	# Smoothly move toward target position
	global_position.x = lerp(global_position.x, target_pos.x, delta * align_speed)
	
	
func _unhandled_input(event):
	
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		
		pitch = clamp(pitch, vertical_min_angle, vertical_max_angle)
		yaw = clamp(yaw, horizontal_min_angle, horizontal_max_angle)
		
		global_rotation_degrees.y = yaw
		global_rotation_degrees.x = pitch
		
	#Global.DEBUG_TEXT.clear()
	#Global.DEBUG_TEXT.add_text(str(pitch))
	#Global.DEBUG_TEXT.add_text("\n")
	#Global.DEBUG_TEXT.add_text(str(yaw))

	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = event.position
		var from = project_ray_origin(mouse_pos)
		var to = from + project_ray_normal(mouse_pos) * 5000.0
		
		print("Ray from:", from, "to:", to);
		
		# Create ray
		var _from = project_ray_origin(mouse_pos)
		var _to = _from + project_ray_normal(mouse_pos) * 5000.0

		# Raycast into world
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(_from, _to)
		var result = space_state.intersect_ray(query)

		print(result)
		
		if result:
			var hit_node = result.collider
			print(hit_node)
			# Example: spawn something as a child of the hit object
			#var decal = hole_scene.instantiate()
			#hit_node.add_child(decal)

			#decal.look_at(result.position + result.normal, Vector3.UP)
			# place it at the hit point (in local coords of hit_node)
			#decal.global_position = result.position
		
		
