extends CharacterBody3D

@export var global_speed:float = 15
@export var min_speed:float = 5

@onready var input_component:InputComponent = %InputComponent
@onready var movement_component: MovementComponent = %MovementComponent

func _ready() -> void:
	movement_component.base_position = global_position

func _physics_process(delta: float) -> void:
	input_component.update()
	
	#print("Move Direction:", input_component.move_dir)
	#print("Mouse Motion at: ", input_component.mouse_delta)
	#print("Mouse Click: ", input_component.mouse_pressed)
	
	movement_component.direction = input_component.move_dir
	movement_component.jump_just_pressed = input_component.jump_pressed
	
	Global.PLAYER_SPEED = clamp(-input_component.move_dir.y * global_speed, min_speed, global_speed)
	
	input_component.clear()
	
	movement_component.tick(delta)
