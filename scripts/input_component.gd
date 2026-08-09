class_name InputComponent extends Node

@export_range(0.2, 2) var mouse_sensitivity:float = 0.2

var move_dir:Vector2 = Vector2.ZERO
var jump_pressed:bool = false
var mouse_delta:Vector2 = Vector2.ZERO
var mouse_pressed:bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func update() -> void:
	move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	jump_pressed = Input.is_action_just_pressed("ui_accept")

# Called after reading inputs
func clear() -> void:
	mouse_delta = Vector2.ZERO
	mouse_pressed = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
	
	if event is InputEventMouseButton:
		mouse_pressed = true
