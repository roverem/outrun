class_name Ui extends CanvasLayer

@onready var coin_label:Label = %Coins

var coins:int = 0

func _ready() -> void:
	Global.UI = self

func increase_coins():
	coins += 1
	coin_label.text = "COINS: " + str(coins)
