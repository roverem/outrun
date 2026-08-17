extends Control

@export var target_object: CarEnemy
@export var offset: Vector3 = Vector3(0, 2.0, 0) # Adjusts UI height over the object

@onready var label:Label = $Label

var camera: Camera3D
var hits:int = 0

func _ready() -> void:
	# Get the active 3D camera
	camera = get_viewport().get_camera_3d()
	target_object.on_hit.connect(_add_hit)
	label.visible = false
	
func _add_hit():
	label.visible = true
	hits += 1
	label.text = "HITS: " + str(hits)

func _process(_delta: float) -> void:
	if not target_object or not camera:
		return
		
	# Check if the object is behind the camera
	if camera.is_position_behind(target_object.global_position):
		visible = false
		return
		
	# Convert 3D world coordinates to 2D screen coordinates
	var world_position = target_object.global_position + offset
	var screen_position = camera.unproject_position(world_position)
	
	# Update the UI position (centered)
	global_position = screen_position - (size / 2)
	visible = true
