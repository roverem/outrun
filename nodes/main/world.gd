extends Node3D

#event: spawn 2 enemies N, 1 power up
@onready var player:CharacterBody3D = %TaxiPlayer

func _ready() -> void:
	Global.PLAYER_CAR = player
	Global.player_registered.emit()
