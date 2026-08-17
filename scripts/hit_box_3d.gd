@tool

class_name HitBox3D extends Area3D

signal hit_hurt_box(hurt_box: HurtBox3D)
const DAMAGE_SOURCE_PLAYER := 0b01
const DAMAGE_SOURCE_MOB := 0b10

@export var damage := 1
@export_flags("Player", "Mob") var source_type := DAMAGE_SOURCE_PLAYER:
	set = set_source_type
	
@export_flags("Player", "Mob") var can_hit := DAMAGE_SOURCE_MOB:
	set = set_can_hit

func set_can_hit(new_value: int) -> void:
	can_hit = new_value
	collision_mask = can_hit

func set_source_type(new_value: int) -> void:
	source_type = new_value
	collision_layer = source_type

func _init() -> void:
	monitoring = true
	monitorable = true
	area_entered.connect(
		func _on_area_entered(area: Area3D) -> void:
			if area is HurtBox3D:
				hit_hurt_box.emit(area)
	)
