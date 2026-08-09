extends CharacterBody3D

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
	
	input_component.clear()
	
	movement_component.tick(delta)
