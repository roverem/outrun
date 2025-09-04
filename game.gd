extends Node3D

@onready var camera_3d: Camera3D = $"sedan-sports"/Camera3D
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
@export var spawner_segment_scene: PackedScene    # TrackSegmentSpawner.tscn
@export var normal_per_spawner: int = 10           # cada X normales…
@export var spawners_in_batch: int = 3            # …insertá Y spawners
@export var move_speed: float = 10.0            # unidades/seg
@export var pool_size: int = 15                # cuántas piezas mantener vivas
@export var segment_length: float = 5.0
@export var default_segment_length: float = 20.0        # fallback si la pieza no lo exporta
@export var spawn_ahead: float = 250.0          # hasta dónde “llenar” por delante
@export var back_buffer: float = 60.0             # cuánto dejamos por detrás

@export var hole_scene:PackedScene
#@onready var segments_root: Node3D = $Segments

@onready var moving_root: Node3D = $MovingRoot
@onready var segments_root: Node3D = $MovingRoot/Segments
@onready var enemies_root: Node3D  = $MovingRoot/Enemies


var angle_range:float = 15.0
var base_position: Vector3
var base_rotation: Vector3
#var _active := []            # Array[Node3D]
var _next_z := 50.0           # dónde colocar la próxima pieza (en +Z)
var _active: Array[Node3D] = []                         # segmentos vivos
var _pending_spawners: Array[TrackSegmentSpawner] = []  # spawners a activar
var _next_z_local := 0.0                                # cursor de colocación (local a MovingRoot)
var _normals_since_spawner := 0

const MAX_FILL_PER_FRAME := 128

func _ready() -> void:
	base_position = camera_3d.position  # guarda la posición inicial
	base_rotation = camera_3d.rotation
	_bootstrap_segments()
	_bootstrap_fill()
	
func _process(delta: float) -> void:
	# Movimiento oscilante en el eje Z
	camera_3d.position.y = base_position.y + sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	
	
	camera_3d.far = 100000
	
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
	_activate_spawners_if_needed()
	_recycle_far()
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
		
func _bootstrap_fill() -> void:
	_active.clear()
	_pending_spawners.clear()
	_next_z_local = 0.0
	for i in range(12): # rellená a gusto
		_spawn_next_segment()

func _spawn_next_segment() -> void:
	var use_spawner := (spawner_segment_scene != null and _normals_since_spawner >= normal_per_spawner)
	if use_spawner:
		for i in range(spawners_in_batch):
			_place_segment(spawner_segment_scene.instantiate())
			_normals_since_spawner = 0
	else:
		_place_segment(segment_scene.instantiate())
		_normals_since_spawner += 1
		
#func _place_segment(seg: Node3D) -> void:
#	segments_root.add_child(seg)
#	
#	# colocar en LOCAL (importante si movés el contenedor)
#	var t := seg.transform
#	t.origin = Vector3(0, 0, _next_z_local)
#	seg.transform = t
#	
#	_active.append(seg)

#	# longitud real
#	var seg_len := default_segment_length
#	if seg is TrackSegment:
#		seg_len = (seg as TrackSegment).length
#		if seg is TrackSegmentSpawner:
#			seg_len = (seg as TrackSegmentSpawner).length
#			_pending_spawners.append(seg as TrackSegmentSpawner)
			
#			_next_z_local += seg_len

func _place_segment(seg: Node3D) -> void:
	if segments_root == null:
		push_error("segments_root es null"); return
		
	segments_root.add_child(seg)

	var t := seg.transform
	t.origin = Vector3(0, 0, _next_z_local)   # LOCAL a MovingRoot
	seg.transform = t
	_active.append(seg)

	var seg_len := _segment_length_safe(seg)

	if seg is TrackSegmentSpawner:
		_pending_spawners.append(seg as TrackSegmentSpawner)

	_next_z_local += seg_len


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
	#segments_root.translate(Vector3(0, 0, -move_speed * delta))
	# (Si tenés elementos que no deben moverse, no los pongas bajo "Segments")
	moving_root.translate(Vector3(0, 0, -move_speed * delta))

func _recycle_segments() -> void:
	# Despawn si una pieza pasó demasiado detrás de la cámara
	var despawn_z := camera_3d.global_transform.origin.z - 50.0
	for i in range(_active.size() - 1, -1, -1):
		var seg := _active[i] as Node3D
		if seg.global_transform.origin.z < despawn_z:
			_active.remove_at(i)
			seg.queue_free()   # destruye de forma segura al final del frame
 
#func _ensure_filled_ahead() -> void:
	# Mantén el “tapete” extendido por delante de la cámara
	#var target_front := camera_3d.global_transform.origin.z +spawn_ahead
	#while _next_z + segments_root.global_transform.origin.z < target_front and _active.size() < pool_size:
		#_spawn_segment_at(_next_z + segments_root.global_transform.origin.z)
#	var target_front_global := camera_3d.global_transform.origin.z + spawn_ahead
#	while _next_z_local + moving_root.global_transform.origin.z < target_front_global:
#		_spawn_next_segment()


func _ensure_filled_ahead() -> void:
	if moving_root == null or camera_3d == null:
		push_error("moving_root o cam null en _ensure_filled_ahead()"); return

	var target_front_global := camera_3d.global_transform.origin.z + spawn_ahead
	var iterations := 0

	while (_next_z_local + moving_root.global_transform.origin.z) < target_front_global:
		_spawn_next_segment()
		iterations += 1
		if iterations > MAX_FILL_PER_FRAME:
			push_error("Aborto fill: superó MAX_FILL_PER_FRAME. Posible length=0 o lógica de avance rota. _next_z_local=" + str(_next_z_local))
			break

#func _recycle_far() -> void:
	#var despawn_z := camera_3d.global_transform.origin.z - back_buffer
	
	# segmentos
	#for i in range(_active.size() - 1, -1, -1):
		#var seg := _active[i] as Node3D
		#if seg.global_transform.origin.z < despawn_z:
			#_active.remove_at(i)
			#seg.queue_free()

func _recycle_far() -> void:
	if camera_3d == null: return
	var despawn_z := camera_3d.global_transform.origin.z - back_buffer

	for i in range(_active.size() - 1, -1, -1):
		var seg := _active[i]
		if seg == null or not is_instance_valid(seg):
			_active.remove_at(i)
			continue
		if seg.global_transform.origin.z < despawn_z:
			_active.remove_at(i)
			seg.queue_free()

	if enemies_root != null:
		for e in enemies_root.get_children():
			var n := e as Node3D
			if n and n.global_transform.origin.z < despawn_z:
				n.queue_free()

#func _activate_spawners_if_needed() -> void:
#	for i in range(_pending_spawners.size() - 1, -1, -1):
#		var sp := _pending_spawners[i]
#		if sp.has_spawned():
#			_pending_spawners.remove_at(i)
#			continue
#			
#		var trigger_z := camera_3d.global_transform.origin.z + sp.trigger_ahead
#		if sp.global_transform.origin.z <= trigger_z:
#			_spawn_from_spawner(sp)
#			sp.mark_spawned()
#			_pending_spawners.remove_at(i)

func _activate_spawners_if_needed() -> void:
	if camera_3d == null: return
	var trigger_base := camera_3d.global_transform.origin.z

	for i in range(_pending_spawners.size() - 1, -1, -1):
		var sp := _pending_spawners[i]
		if sp == null or not is_instance_valid(sp):
			_pending_spawners.remove_at(i)
			continue

		if sp.has_spawned():
			_pending_spawners.remove_at(i)
			continue

		var trigger_z := trigger_base + sp.trigger_ahead
		if sp.global_transform.origin.z <= trigger_z:
			_spawn_from_spawner(sp)
			sp.mark_spawned()
			_pending_spawners.remove_at(i)
			
#func _spawn_from_spawner(sp: TrackSegmentSpawner) -> void:
#	if sp.enemy_scene == null:
#		return
#	
#	var points: Array[Node3D] = sp.get_spawn_points()
#	if points.is_empty():
#		points = [sp]  # ahora es válido: sp es Node3D
#		
#	var to_spawn: int = int(min(sp.spawn_count, points.size()))
#	for n in range(to_spawn):
#		var enemy := sp.enemy_scene.instantiate() as Node3D
#		enemies_root.add_child(enemy)
		
#		var pos := points[n].global_transform.origin
#		pos.x += randf_range(-sp.randomize_xy.x, sp.randomize_xy.x)
#		pos.y += randf_range(-sp.randomize_xy.y, sp.randomize_xy.y)
	
#		var et := enemy.global_transform
#		et.origin = pos
#		enemy.global_transform = et
		
		# opcional: hacer que “vengan” un poco más rápido que el mundo
#		if enemy.has_method("set_forward_speed"):
#			enemy.call("set_forward_speed", move_speed * 1.1)

func _spawn_from_spawner(sp: TrackSegmentSpawner) -> void:
	if sp == null or enemies_root == null:
		push_error("Spawner o enemies_root null"); return
	if sp.enemy_scene == null:
		push_warning("Spawner sin enemy_scene: " + sp.name); return

	var points: Array[Node3D] = sp.get_spawn_points()
	if points.is_empty():
		points = [sp]  # fallback válido porque ahora es Array[Node3D]

	var to_spawn: int = int(min(sp.spawn_count, points.size()))
	for n in range(to_spawn):
		var enemy := sp.enemy_scene.instantiate() as Node3D
		if enemy == null:
			push_error("enemy_scene.instantiate() devolvió null"); continue

		enemies_root.add_child(enemy)

		var pos := points[n].global_transform.origin
		pos.x += randf_range(-sp.randomize_xy.x, sp.randomize_xy.x)
		pos.y += randf_range(-sp.randomize_xy.y, sp.randomize_xy.y)

		var et := enemy.global_transform
		et.origin = pos
		enemy.global_transform = et

		if enemy.has_method("set_forward_speed"):
			enemy.call("set_forward_speed", move_speed * 1.1)

func _segment_length_safe(seg: Node3D) -> float:
	var seg_len: float = default_segment_length

	if seg is TrackSegment:
		seg_len = (seg as TrackSegment).length
	elif seg is TrackSegmentSpawner:
		seg_len = (seg as TrackSegmentSpawner).length

	# Guarda básica (evita 0 o negativos que rompen el fill)
	if seg_len <= 0.0:
		push_error("Segment length inválido (" + str(seg_len) + ") en: " + seg.name + ". Usando default " + str(default_segment_length))
		seg_len = max(default_segment_length, 0.01)

	return seg_len
