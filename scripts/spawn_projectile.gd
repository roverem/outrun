class_name SpawnProjectileComponent extends Node

@export var spawn_point:Node3D
@export var projectile:PackedScene
@export var camera:Camera3D

var can_shoot:bool = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not can_shoot:
			return
		
		var proj:Projectile = projectile.instantiate()		
		get_tree().current_scene.add_child(proj)
		proj.spawn()
		proj.global_position = spawn_point.global_position
		
		var forward_direction = -camera.global_transform.basis.z.normalized()
		proj.direction = forward_direction
		
