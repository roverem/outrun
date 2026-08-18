extends Node3D

@onready var coins:Node3D = %coins
var starting_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_position = global_position.z


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(global_position.z)
	global_position.z += Global.PLAYER_SPEED * delta
	
	#reset
	if global_position.z > 20:
		global_position.z = starting_position 
		var children:Array = coins.get_children()
		for coin:Coin in children:
			coin.restore()
		
