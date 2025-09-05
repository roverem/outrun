extends Node3D

@onready var debug_text:RichTextLabel = %DebugText

@export var segment_scene: PackedScene          # arrastra TrackSegment.tscn
@export var move_speed: float = 10.0            # unidades/seg
@export var pool_size: int = 15                # cuántas piezas mantener vivas
@export var segment_length: float = 5.0        # fallback si la pieza no lo exporta
@export var spawn_ahead: float = 250.0          # hasta dónde “llenar” por delante
@export var hole_scene:PackedScene

@onready var segments_root: Node3D = $Segments
@onready var camera_3d:Camera3D = %Camera3D
var angle_range:float = 15.0

var _active := []            # Array[Node3D]
var _next_z := 50.0           # dónde colocar la próxima pieza (en +Z)

func _ready() -> void:
	Global.DEBUG_TEXT = debug_text
	_bootstrap_segments()
	
func _process(delta: float) -> void:
	
	_scroll_world(delta)
	_recycle_segments()
	_ensure_filled_ahead()
		
		
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
