class_name Player
extends CharacterBody3D

@export var steer_speed: float = 3.5
@export var max_steer: float = 6.5
@export var tilt_angle: float = 0.0
@export var tilt_speed: float = 5.0
@export var yaw_angle: float = 25.0
@export var pitch_angle: float = 10.0

@export var jump_height: float = 2.0 # how high the car jumps
@export var jump_speed: float = 5.0 # how fast it goes up
@export var gravity: float = 9.8 # how fast it falls down

var scroll_speed: float = 0.0 # current speed
@export var acceleration: float = 5.0 # how fast it accelerates with UP
@export var deceleration: float = 3.0 # how fast it slows down when no input
@export var max_speed: float = 20.0 # cap the speed
@export var min_speed: float = 2

var base_position: Vector3
var vertical_velocity: float = 0.0
var is_jumping: bool = false

var jumping_yaw: float = 0
var is_jump_moving:bool = false
var jumping_direction:float = 0
var just_landed = false

@onready var debug_text: RichTextLabel = %DebugText
@onready var just_landed_timer:Timer = %JustLandedTimer

func _ready():
	Global.PLAYER_CAR = self
	base_position = global_position	

func _process(delta):
	var input_dir := 0.0
	if Input.is_action_pressed("ui_right") and not is_jumping:
		input_dir -= 1
	if Input.is_action_pressed("ui_left") and not is_jumping:
		input_dir += 1
	
	if is_jump_moving:
		input_dir = jumping_direction * abs(jumping_yaw / yaw_angle)
	
	# Move left/right
	global_position.x = clamp(global_position.x + input_dir * steer_speed * delta, -max_steer, max_steer)
	global_position.z = base_position.z
	
	# --- Acceleration ---
	if Input.is_action_pressed("ui_up"):
		scroll_speed += acceleration * delta
	else:
		# --- Natural deceleration ---
		scroll_speed -= deceleration * delta

	# clamp between 0 and max_speed
	scroll_speed = clamp(scroll_speed, min_speed, max_speed)
	Global.PLAYER_SPEED = scroll_speed

	# DESPUES DE SALTAR DISPARAR UN TIMER PARA EVITAR QUE PUEDAS DOBLAR HASTA DESPUES
	# Jump logic
	if Input.is_action_just_pressed("ui_accept") and not is_jumping:
		vertical_velocity = jump_speed
		is_jumping = true
		jumping_yaw = rotation_degrees.y
		if jumping_yaw != 0:
			is_jump_moving = true
			jumping_direction = input_dir 

	if is_jumping:
		global_position.y += vertical_velocity * delta
		vertical_velocity -= gravity * delta  # apply gravity
		 
		if global_position.y <= base_position.y:
			global_position.y = base_position.y
			vertical_velocity = 0.0
			is_jumping = false
			is_jump_moving = false
			

	# Stop logic (down key resets to base position instantly)
	if Input.is_action_just_pressed("ui_down"):
		global_position = base_position
		vertical_velocity = 0.0

	# Tilts
	var target_roll = input_dir * tilt_angle           # Z axis lean
	var target_yaw = input_dir * yaw_angle             # Y axis slight twist
	var target_pitch = -abs(input_dir) * pitch_angle   # X axis dip
	
	if is_jumping:
		target_yaw = jumping_yaw 
	
	
	
	if is_jumping:
		if vertical_velocity > 0:
			target_pitch = -pitch_angle
		else:
			target_pitch = pitch_angle

	rotation_degrees.z = lerp(rotation_degrees.z, target_roll, delta * tilt_speed)
	rotation_degrees.y = lerp(rotation_degrees.y, target_yaw, delta * (tilt_speed * 0.35))
	rotation_degrees.x = lerp(rotation_degrees.x, target_pitch, delta * (tilt_speed * 0.5))


func _on_just_landed_timer_timeout() -> void:
	pass # Replace with function body.
