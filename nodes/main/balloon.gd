extends Node3D

@onready var follow_component:FollowBehindComponent = %FollowBehindComponent


func _process(delta: float) -> void:
	follow_component.tick(delta)
