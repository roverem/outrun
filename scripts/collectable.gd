class_name Collectable extends Area3D

@export var collector:Node3D

signal collected

func _init() -> void:
	monitoring = true
	monitorable = false
	
	collector = Global.PLAYER_CAR
	if collector == null:
		Global.player_registered.connect(func():collector = Global.PLAYER_CAR)
	
	body_entered.connect(on_body_entered)
	
func on_body_entered(body:Node3D)->void:
	if body == collector:
		collected.emit()
