class_name Projectile extends Node3D

@export var max_speed:float = 20.0
@export var initial_size:Vector3 = Vector3.ZERO
@export var max_size:Vector3 = Vector3.ONE
@export var growth_time:float = 1

@onready var timer:Timer = %Timer

var direction:Vector3 = Vector3.ZERO
var speed:float = 0.0

func _ready() -> void:
	scale = initial_size
	timer.timeout.connect(queue_free)

func spawn()->void:
	timer.start()
	
	var tween:Tween = create_tween()
	tween.tween_interval(0.2)
	tween.set_parallel(true)
	tween.tween_property( self, "scale", max_size, growth_time)
	tween.tween_property(self, "speed", max_speed, growth_time)
	

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	rotation_degrees.x += delta
