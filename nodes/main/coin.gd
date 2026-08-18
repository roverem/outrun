@tool
class_name Coin extends Node3D

var original_position:Vector3

@export var rotation_speed_collected:float = 200.0

@onready var floating_component:FloatingComponent = %FloatingComponent
@onready var collectable_component:Collectable = %Collectable



func _ready() -> void:
	original_position = position
	collectable_component.collected.connect(collect)
	
		
func restore():
	visible = true

func collect():
	Global.UI.increase_coins()
	floating_component.stop()
	animate_collect()
	
func animate_collect()->void:
	var tween = create_tween()
	tween.tween_property(self, "position:y", original_position.y + 10, 0.5)
	tween.set_parallel()
	tween.tween_property(self, "rotation_degrees:y", rotation_degrees.y + 900, 0.1)
	tween.finished.connect(_hide)
	
func _hide():
	floating_component.resume_floating()
	visible = false

func _process(delta: float) -> void:
	floating_component.update(delta)
