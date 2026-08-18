class_name SpawnProjectileComponent extends Node

@export var spawn_point:Node3D
@export var projectile:PackedScene
@export var camera:Camera3D
@export var to_animate:Node3D
@export var shoot_vfx:PackedScene

@export var shoot_delay:float = 0.5

var can_shoot:bool = true
var shoot_timer:Timer

func _ready() -> void:
	shoot_timer = Timer.new()
	add_child(shoot_timer)
	shoot_timer.one_shot = true
	shoot_timer.wait_time = shoot_delay
	shoot_timer.timeout.connect(_reset_shoot)
	
func _reset_shoot()->void:
	can_shoot = true
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not can_shoot:
			return
		
		can_shoot = false
		
		to_animate.shoot()
		await to_animate.done_shooting
		
		var emission:Node3D = shoot_vfx.instantiate()
		emission.transform = spawn_point.transform
		emission.scale = Vector3.ONE * 0.8
		add_sibling(emission)
		
		var proj:Projectile = projectile.instantiate()		
		get_tree().current_scene.add_child(proj)
		proj.spawn()
		proj.global_position = spawn_point.global_position
		
		var forward_direction = -camera.global_transform.basis.z.normalized()
		proj.direction = forward_direction
		
		shoot_timer.start()
