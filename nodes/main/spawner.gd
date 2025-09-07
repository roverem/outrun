class_name Spawner
extends Node3D


@export var segments: Array[PackedScene]
@export var track:Track
@export var random_amounts: Array[float] = [1]

@onready var spawn_timer:Timer = $Timer



func spawn_random()->void:
	var scene:PackedScene = segments.pick_random()
	var instance = scene.instantiate()
	track.spawn(instance)


func _on_timer_timeout() -> void:
	for amount in random_amounts.pick_random():
		spawn_random()
