extends Node3D

@onready var camera_3d: Camera3D = $"sedan-sports"/Camera3D
@export var amplitude: float = 0.2  # distancia máxima hacia adelante/atrás
@export var speed: float = 0.3      # velocidad de oscilación

var base_position: Vector3

func _ready() -> void:
	base_position = camera_3d.position  # guarda la posición inicial
	
func _process(delta: float) -> void:
	# Movimiento oscilante en el eje Z
	camera_3d.position.y = base_position.y + sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude
