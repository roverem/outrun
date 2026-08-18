class_name FloatingComponent extends Node

@export var floater:Node3D

@export var lower_pos:float = 0.2
@export var upper_pos:float = 0.8
@export var up_speed:float = 0.5
@export var down_speed:float = 0.8

@export var rotation_speed:float = 80.0

var starting_position:Vector3
var tween:Tween
var is_rotating:bool = true

func _ready() -> void:
	starting_position = floater.position
	tween_up_down()
	
func tween_up_down():
	tween = create_tween()
	tween.tween_property(floater, "position:y", starting_position.y + lower_pos, down_speed)
	tween.tween_property(floater, "position:y", starting_position.y + upper_pos, up_speed)
	tween.finished.connect(tween_up_down)

func stop():
	tween.kill()
	is_rotating = false

func resume_floating():
	floater.position = starting_position
	is_rotating = true
	tween_up_down()
	
func update(delta:float)->void:
	if is_rotating:
		floater.rotation_degrees.y += delta * rotation_speed
