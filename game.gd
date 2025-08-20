extends Node3D

@onready var camera_3d: Camera3D = $Sprite3D/Camera3D
@export var amplitude: float = 1.0  # distancia máxima hacia adelante/atrás
@export var speed: float = 2.0      # velocidad de oscilación

var base_position: Vector3

func _ready() -> void:
	base_position = camera_3d.position  # guarda la posición inicial
	
func _process(delta: float) -> void:
	# Movimiento oscilante en el eje Z
	camera_3d.position.z = base_position.z + sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude
