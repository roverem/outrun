class_name CarEnemy extends CharacterBody3D

signal on_hit

@export var _car_skin: Node3D
@onready var _hurt_box_3d: HurtBox3D = %HurtBox3D

var starting_position:Vector3

var hp:int = 2

func _ready() -> void:
	_hurt_box_3d.took_hit.connect(_on_hurt_box_took_hit)
	starting_position = global_position
	
func _on_hurt_box_took_hit(hit_box: HitBox3D) -> void:
		var tween:Tween = create_tween()
		
		on_hit.emit()
		
		hp -= 1
		
		tween.tween_property(_car_skin, "rotation_degrees:y", -11, 0.3 )
		tween.tween_property(_car_skin, "rotation_degrees:y", 11, 0.3 )
		tween.tween_property(_car_skin, "rotation_degrees:y", -11, 0.3 )
		tween.tween_property(_car_skin, "rotation_degrees:y", 0, 0.3 )
		if hp == 0:
			tween.tween_property(self, "global_position:z", 10, 0)
			tween.tween_property(self, "global_position:z", starting_position.z, 1)
			hp = 2
