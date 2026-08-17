class_name Projectile extends HitBox3D

@export var max_speed:float = 20.0
@export var achieve_max_speed_time:float = 0.5
@export var max_rotation:float = 300
@export var delay_time: float = 0.1
@export var growth_time:float = 1
@export var initial_size:Vector3 = Vector3.ONE * 0.1
@export var max_size:Vector3 = Vector3.ONE * 0.5

@export var impact_vfx: PackedScene = null

@onready var timer:Timer = %Timer

var direction:Vector3 = Vector3.ZERO
var speed:float = 0.0
var spin_rotation:float = 0.0

func _ready() -> void:
	hit_hurt_box.connect(_on_hit)

	scale = initial_size
	timer.timeout.connect(_destroy)
	
func _destroy()->void:
	hit_hurt_box.disconnect(_on_hit)
	queue_free()

func _on_hit(_node: HurtBox3D) -> void:
	var impact: Node3D = impact_vfx.instantiate()
	impact.transform = transform
	add_sibling(impact)

	_destroy()


func spawn()->void:
	timer.start()
	speed = max_speed * 0.1
	var tween:Tween = create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(self, "spin_rotation", max_rotation, delay_time)
	tween.tween_property(self, "speed", max_speed, achieve_max_speed_time)
	tween.tween_property( self, "scale", max_size, growth_time)
	
	

func _physics_process(delta: float) -> void:
	#print(speed, scale, spin_rotation)
	global_position += direction * speed * delta
	rotation_degrees.y += delta * spin_rotation
