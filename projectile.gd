class_name Projectile extends Node3D

@export var max_speed:float = 20.0
@export var achieve_max_speed_time:float = 0.5
@export var max_rotation:float = 300
@export var delay_time: float = 0.1
@export var growth_time:float = 0.2
@export var initial_size:Vector3 = Vector3.ONE * 0.1
@export var max_size:Vector3 = Vector3.ONE * 0.5

@onready var timer:Timer = %Timer

var direction:Vector3 = Vector3.ZERO
var speed:float = 0.0
var spin_rotation:float = 0.0

func _ready() -> void:
	scale = initial_size
	timer.timeout.connect(queue_free)

func spawn()->void:
	timer.start()
	speed = max_speed * 0.1
	var tween:Tween = create_tween()
	tween.tween_property(self, "spin_rotation", max_rotation, delay_time)
	#tween.tween_interval(delay_time)
	
	tween.tween_property( self, "scale", max_size, growth_time)
	tween.set_parallel(true)
	tween.tween_property(self, "speed", max_speed, achieve_max_speed_time)
	

func _physics_process(delta: float) -> void:
	print(speed, scale, spin_rotation)
	global_position += direction * speed * delta
	rotation_degrees.y += delta * spin_rotation
