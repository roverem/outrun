class_name HitScanComponent extends Node

@export var spawn_point:Node3D

var can_shoot:bool = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not can_shoot:
			return
		
		var mouse_pos = event.position
		var from = spawn_point.project_ray_origin(mouse_pos)
		var to = from + spawn_point.project_ray_normal(mouse_pos) * 5000.0
		
		print("Ray from:", from, "to:", to);
		
		# Create ray
		var _from = spawn_point.project_ray_origin(mouse_pos)
		var _to = _from + spawn_point.project_ray_normal(mouse_pos) * 5000.0

		# Raycast into world
		var space_state = spawn_point.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(_from, _to)
		var result = space_state.intersect_ray(query)
		
		if result:
			var hit_node = result.collider
			if hit_node is CharacterBody3D: #TaxiPlayer
				return
			if hit_node.get_parent() is TrackSegment:
				return
			
			hit_node.get_parent().queue_free()
