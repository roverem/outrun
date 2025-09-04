extends Node3D

@onready var camera_3d: Camera3D = %Camera3D
@export var amplitude: float = 0.2  # distancia máxima hacia adelante/atrás
@export var speed: float = 0.3      # velocidad de oscilación
@onready var directional_light_3d: SpotLight3D = $DirectionalLight3D
@export_range(-220, -180) var horizontal_min_angle
@export_range(-180, -100) var horizontal_max_angle
@export_range(-45, 0) var vertical_min_angle
@export_range(0, 90) var vertical_max_angle
@export_range(0.2, 4) var mouse_sensitivity:float

@onready var debug_text:RichTextLabel = %DebugText

@export var segment_scene: PackedScene          # arrastra TrackSegment.tscn
@export var move_speed: float = 10.0            # unidades/seg
@export var pool_size: int = 15                # cuántas piezas mantener vivas
@export var segment_length: float = 5.0        # fallback si la pieza no lo exporta
@export var spawn_ahead: float = 250.0          # hasta dónde “llenar” por delante
@export var hole_scene:PackedScene
@onready var segments_root: Node3D = $Segments

var angle_range:float = 15.0
var base_position: Vector3
var base_rotation: Vector3
var _active := []            # Array[Node3D]
var _next_z := 50.0           # dónde colocar la próxima pieza (en +Z)

func _ready() -> void:
	base_position = camera_3d.position  # guarda la posición inicial
	base_rotation = camera_3d.rotation
	_bootstrap_segments()
	
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
	
	camera_3d.rotation.x = clamp(base_rotation.x + vertical_rate * mouse_sensitivity, deg_to_rad( vertical_min_angle), deg_to_rad( vertical_max_angle) )
	camera_3d.rotation.y = clamp(base_rotation.y + horizontal_rate * mouse_sensitivity, deg_to_rad(horizontal_min_angle), deg_to_rad(horizontal_max_angle))
	
	debug_text.add_text("\n camera rotation horizontal" + str( rad_to_deg(camera_3d.rotation.y)) + " vertical: " + str(rad_to_deg(camera_3d.rotation.x)) )
	debug_text.add_text("\n horizontal angle " + str( horizontal_min_angle) + " : " + str(  horizontal_max_angle ) )
	debug_text.add_text("\n vertical angle " + str( vertical_min_angle) + " : " + str( vertical_max_angle  ) )
	
	#print(camera_3d.rotation)
	#var mouse_pos = event.position
	var from = camera_3d.project_ray_origin(mouse_pos)
	var to = from + camera_3d.project_ray_normal(mouse_pos) * 1000.0
	directional_light_3d.look_at(to)
	
	_scroll_world(delta)
	_recycle_segments()
	_ensure_filled_ahead()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = event.position
		var from = camera_3d.project_ray_origin(mouse_pos)
		var to = from + camera_3d.project_ray_normal(mouse_pos) * 5000.0
		
		print("Ray from:", from, "to:", to);
		
		# Create ray
		var _from = camera_3d.project_ray_origin(mouse_pos)
		var _to = _from + camera_3d.project_ray_normal(mouse_pos) * 5000.0

		# Raycast into world
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(_from, _to)
		var result = space_state.intersect_ray(query)

		print(result)
		
		if result:
			var hit_node = result.collider
			print(hit_node)
			# Example: spawn something as a child of the hit object
			var decal = hole_scene.instantiate()
			hit_node.add_child(decal)

			decal.look_at(result.position + result.normal, Vector3.UP)
			# place it at the hit point (in local coords of hit_node)
			decal.global_position = result.position
		
		
		
		
func _bootstrap_segments() -> void:
	_next_z = 0.0
	# Spawnea piezas hasta cubrir spawn_ahead
	while _next_z < spawn_ahead and _active.size() < pool_size:
		_spawn_segment_at(_next_z)

func _spawn_segment_at(z: float) -> void:
	var seg := segment_scene.instantiate() as Node3D
	segments_root.add_child(seg)
	
	var t := seg.global_transform
	t.origin = Vector3(0.0, 0.0, z)
	seg.global_transform = t
	_active.append(seg)
	# Avanza el cursor según el largo real de la pieza (si lo exporta), o el fijo:
	var seg_len: float = segment_length  # fallback
	if seg is TrackSegment:
		seg_len = (seg as TrackSegment).length  # tipado, sin Variant  //tomar valor de un valor de z
	 # colocar centro	
	_next_z += seg_len

func _scroll_world(delta: float) -> void:
	# Mueve TODAS las piezas hacia -Z (el auto “parece” ir hacia +Z)
	# Opción A: mover el contenedor entero (barato):
	segments_root.translate(Vector3(0, 0, -move_speed * delta))
	# (Si tenés elementos que no deben moverse, no los pongas bajo "Segments")

func _recycle_segments() -> void:
	# Despawn si una pieza pasó demasiado detrás de la cámara
	var despawn_z := camera_3d.global_transform.origin.z - 50.0
	for i in range(_active.size() - 1, -1, -1):
		var seg := _active[i] as Node3D
		if seg.global_transform.origin.z < despawn_z:
			_active.remove_at(i)
			seg.queue_free()   # destruye de forma segura al final del frame
 
func _ensure_filled_ahead() -> void:
	# Mantén el “tapete” extendido por delante de la cámara
	var target_front := camera_3d.global_transform.origin.z +spawn_ahead
	while _next_z + segments_root.global_transform.origin.z < target_front and _active.size() < pool_size:
		_spawn_segment_at(_next_z + segments_root.global_transform.origin.z)
