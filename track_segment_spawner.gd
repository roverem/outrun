class_name TrackSegmentSpawner
extends Node3D

@export var length: float = 20.0
@export var enemy_scene: PackedScene
@export var spawn_count: int = 2
@export var randomize_xy: Vector2 = Vector2(0.5, 0.0)
@export var trigger_ahead: float = 40.0

var _spawned := false
var _spawn_points: Array[Marker3D] = []

func _ready() -> void:
	for m in find_children("", "Marker3D", true, false):
		_spawn_points.append(m as Marker3D)

func get_spawn_points() -> Array[Node3D]:
	var pts: Array[Node3D] = []
	for m in find_children("", "Marker3D", true, false):
		pts.append(m as Marker3D)  # Marker3D hereda de Node3D
	return pts

func has_spawned() -> bool:
	return _spawned

func mark_spawned() -> void:
	_spawned = true
