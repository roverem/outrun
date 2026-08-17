@tool

class_name HurtBox3D extends Area3D


signal took_hit(hit_box: HitBox3D)

@export_flags("Player", "Mob") var vulnerable_to := DAMAGE_SOURCE_PLAYER:
	set = set_vulnerable_to
@export_flags("Player", "Mob") var owner_type := DAMAGE_SOURCE_PLAYER:
	set = set_owner_type

func set_vulnerable_to(new_value: int) -> void:
	vulnerable_to = new_value
	collision_mask = vulnerable_to

func set_owner_type(new_value: int) -> void:
	owner_type = new_value
	collision_layer = owner_type

func _init() -> void:
	monitoring = true
	monitorable = true
	area_entered.connect(
		func _on_area_entered(area: Area3D) -> void:
			if area is HitBox3D:
				took_hit.emit(area)
	)

const DAMAGE_SOURCE_PLAYER := 0b01
const DAMAGE_SOURCE_MOB := 0b10
