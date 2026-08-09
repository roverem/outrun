class_name MovementComponent extends Node

@export var body: CharacterBody3D
@export var model: Node3D

@export var steer_speed: float = 3.5
@export var max_steer: float = 6.5
@export var tilt_angle: float = 0.0
@export var tilt_speed: float = 5.0
@export var yaw_angle: float = 25.0


var direction:Vector2 = Vector2.ZERO
var base_position:Vector3 = Vector3.ZERO

# Jump
@export var jump_height: float = 0.4 # ALTURA DEL SALTO EN CANTIDAD DE AUTOS
@export var jump_speed: float = 0.4 # DURACIÓN DEL SALTO EN SEGUNDOS
@export var pitch_angle: float = 4.0

var jump_just_pressed:bool = false
var is_jumping:bool = false
var jumping_yaw: float = 0
var is_jump_moving:bool = false
var jumping_direction:Vector2 = Vector2.ZERO
var just_landed:bool = false
var jump_tween:Tween

func tick(delta:float)->void:
	
	# Avoid turning mid-air
	if is_jump_moving:
		direction.x = jumping_direction.x * abs(jumping_yaw / yaw_angle)
		
	# Position
	body.global_position.x = clamp(body.global_position.x + direction.x * steer_speed * delta, -max_steer, max_steer)
	body.global_position.z = base_position.z + direction.y * 10
	body.global_position.y = 0
	
	# Jump
	if jump_just_pressed and not is_jumping:
		_execute_jump()
	
	# Tilts
	var target_roll = -direction.x * tilt_angle           # Z axis lean
	var target_yaw = -direction.x * yaw_angle             # Y axis slight twist
	var target_pitch = abs(direction.x) * pitch_angle     # X axis dip
	
	if is_jumping:
		target_yaw = jumping_yaw 
		#target_pitch = jumping_direction.y * pitch_angle
	
	body.rotation_degrees.z = lerp(body.rotation_degrees.z, target_roll, delta * tilt_speed)
	body.rotation_degrees.y = lerp(body.rotation_degrees.y, target_yaw, delta * (tilt_speed * 0.35))
	#body.rotation_degrees.x = target_pitch #lerp(body.rotation_degrees.x, target_pitch, delta * (tilt_speed * 0.5))

func _execute_jump()->void:
	is_jumping = true
	if jumping_yaw != 0:
		is_jump_moving = true
		jumping_direction.x = direction.x
		
	jump_tween = create_tween()
	jump_tween.tween_property(body, "global_position:y", jump_height, jump_speed * 0.5)
	jump_tween.tween_property(body, "global_position:y", base_position.y, jump_speed * 0.5)
	jump_tween.tween_callback( func():
		is_jumping = false
		is_jump_moving = false
		jumping_direction = Vector2.ZERO
	)
	
	var pitch_tween = create_tween()
	pitch_tween.tween_property(body, "rotation_degrees:x", pitch_angle, jump_speed * 0.25)
	pitch_tween.tween_property(body, "rotation_degrees:x", 0, jump_speed * 0.25)
	pitch_tween.tween_property(body, "rotation_degrees:x", -pitch_angle, jump_speed * 0.25)
	pitch_tween.tween_property(body, "rotation_degrees:x", 0, jump_speed * 0.25)
