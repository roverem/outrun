# TrackSpawnerLite.gd
extends Node3D
class_name TrackSpawnerLite

# Tramos posibles (pueden ser 1 o varios tipos)
@export var segment_scenes: Array[PackedScene] = []

# Velocidad y cobertura visual
@export var speed: float = 30.0
@export var target_visible_length: float = 250.0   # "largo de pista" visible/activa
@export var default_length: float = 20.0           # si no hay anclas ni length

# Si tus piezas tienen Marker3D de entrada/salida (recomendado)
@export var use_anchors: bool = true
@export var start_anchor_path: NodePath = NodePath("Start")
@export var end_anchor_path: NodePath   = NodePath("End")

@export var player_path: NodePath                   # arrastrá tu Player o Camera3D
@export var keep_ahead: float = 200.0               # cuánto “camino” mantener por delante del player
@export var despawn_behind: float = 40.0            # cuánto dejar atrás antes de reciclar

@onready var _player: Node3D = get_node("../Player") as Node3D

# Estado
var _segments: Array[Node3D] = []   # ordenados de adelante→atrás
var _accum_length: float = 0.0

func _ready() -> void:
	# 1) Usamos los hijos ya puestos en la escena como “llenado inicial”
	for c in get_children():
		if c is Node3D:
			_segments.append(c as Node3D)
	# Si no hay, instanciamos uno
	if _segments.is_empty():
		_add_segment_at_end()

	# Ordenamos por z para tener la cadena bien armada
	_segments.sort_custom(func(a, b):
		return (a.global_transform.origin.z < b.global_transform.origin.z)
	)

	# Alinear los que ya están puestos para eliminar gaps
	for i in range(1, _segments.size()):
		_align_after(_segments[i], _segments[i-1])

	# Extender hasta cubrir el target_visible_length
	_fill_to_target_length()

func _process(delta: float) -> void:
	# Si estás haciendo pseudo-3D: mové TODO el camino en -Z
	translate(Vector3(0, 0, -speed * delta))
	
	# Spawnear por delante hasta cubrir el keep_ahead desde el player
	_ensure_ahead()
	# Reciclar por detrás cuando el primer tramo queda lejos del player
	_recycle_behind()

# ---------------- helpers ----------------

func _fill_to_target_length() -> void:
	var total := _chain_length()
	var safety := 64
	var iter := 0
	while total < target_visible_length and iter < safety:
		var seg := _add_segment_at_end()
		if seg == null: break
		total = _chain_length()
		iter += 1

func _chain_length() -> float:
	if _segments.is_empty(): return 0.0
	var start_z := _get_start_z(_segments[0])
	var end_z   := _get_end_z(_segments.back())
	return end_z - start_z

func _add_segment_at_end() -> Node3D:
	if segment_scenes.is_empty(): return null
	var scene := segment_scenes[randi() % segment_scenes.size()]
	var seg := scene.instantiate() as Node3D
	add_child(seg)

	if _segments.is_empty():
		# primer tramo: se queda donde está
		pass
	else:
		_align_after(seg, _segments.back())

	_segments.append(seg)
	return seg

func _align_after(seg: Node3D, prev: Node3D) -> void:
	if use_anchors:
		var s := _get_anchor(seg, start_anchor_path)
		var e := _get_anchor(prev, end_anchor_path)
		if s and e:
			var delta := e.global_transform * s.global_transform.affine_inverse()
			seg.global_transform = delta * seg.global_transform
			return
	# Fallback lineal si no hay anclas
	var L := _length_of(prev)
	var t := seg.global_transform
	t.origin = prev.global_transform.origin + Vector3(0, 0, L)
	seg.global_transform = t

func _get_anchor(seg: Node3D, path: NodePath) -> Marker3D:
	if seg.has_node(path):
		return seg.get_node(path) as Marker3D
	return null

func _length_of(seg: Node3D) -> float:
	# Si tenés export var length en la escena del tramo:
	if "length" in seg:
		var raw = seg.get("length")
		if typeof(raw) in [TYPE_FLOAT, TYPE_INT]:
			var L := float(raw)
			if L > 0.0: return L
	return default_length

func _get_start_z(seg: Node3D) -> float:
	if use_anchors:
		var s := _get_anchor(seg, start_anchor_path)
		if s: return s.global_transform.origin.z
	return seg.global_transform.origin.z

func _get_end_z(seg: Node3D) -> float:
	if use_anchors:
		var e := _get_anchor(seg, end_anchor_path)
		if e: return e.global_transform.origin.z
	return seg.global_transform.origin.z + _length_of(seg)

func _ensure_ahead() -> void:
	if _segments.is_empty():
		_add_segment_at_end()
		return

	var target_z := _player.global_transform.origin.z + keep_ahead
	var safety := 64
	var it := 0
	while _get_end_z(_segments.back()) < target_z and it < safety:
		_add_segment_at_end()
		it += 1

func _recycle_behind() -> void:
	if _segments.size() < 2:
		return

	var cutoff := _player.global_transform.origin.z - despawn_behind
	# Mientras el END del primero haya quedado atrás del cutoff, reciclarlo al final
	while _get_end_z(_segments[0]) < cutoff:
		var first := _segments[0]            # Variant
		var last  := _segments[_segments.size()-1]
		_align_after(first, last)   # lo engancho detrás del último
		_segments.append(first)
