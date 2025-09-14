extends Camera3D

@export var amplitude: float = 0.2  # distancia máxima hacia adelante/atrás
@export var speed: float = 0.3      # velocidad de oscilación
@export_range(-360, 360) var horizontal_min_angle = -260
@export_range(-360, 360) var horizontal_max_angle = -110
@export_range(-360, 360) var vertical_min_angle = -80
@export_range(-360, 360) var vertical_max_angle = 20
@export_range(0.2, 2) var mouse_sensitivity:float = 0.2
@onready var directional_light_3d: SpotLight3D = $DirectionalLight3D
@export var align_speed: float = 2.0   # how fast the camera recenters

@onready var flare:Sprite3D = %flare;
@onready var flare_delay:Timer = %flare_delay
@onready var can_shoot_delay:Timer = %can_shoot
@onready var shotgun:Sprite3D = %shotgun

var can_shoot:bool = true
var base_position: Vector3
var base_rotation: Vector3
var car: Node3D

var shotgun_base_position

var yaw:float = 0.0
var pitch:float = 0.0

func _ready():
	base_position = global_position
	base_rotation = global_rotation_degrees
	
	shotgun_base_position = shotgun.position
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	can_shoot_delay.timeout.connect(_reset_can_shoot)
	flare_delay.timeout.connect(_on_timer_timeout)
	
	

func _process(delta: float) -> void:
	if car == null:
		car = Global.PLAYER_CAR
		
	global_position.y = base_position.y + sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude

	# Target is always behind the car (aligned in X)
	var target_pos = base_position
	target_pos.x = car.global_position.x

	# Smoothly move toward target position
	global_position.x = lerp(global_position.x, target_pos.x, delta * align_speed)
	
	
	
func _unhandled_input(event):
	
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		
		pitch = clamp(pitch, vertical_min_angle, vertical_max_angle)
		yaw = clamp(yaw, horizontal_min_angle, horizontal_max_angle)
		
		global_rotation_degrees.y = yaw
		global_rotation_degrees.x = pitch
		
	#Global.DEBUG_TEXT.clear()
	#Global.DEBUG_TEXT.add_text(str(pitch))
	#Global.DEBUG_TEXT.add_text("\n")
	#Global.DEBUG_TEXT.add_text(str(yaw))

	if event is InputEventMouseButton and event.pressed:
		if not can_shoot:
			return
			
		var mouse_pos = event.position
		var from = project_ray_origin(mouse_pos)
		var to = from + project_ray_normal(mouse_pos) * 5000.0
		
		print("Ray from:", from, "to:", to);
		
		# Create ray
		var _from = project_ray_origin(mouse_pos)
		var _to = _from + project_ray_normal(mouse_pos) * 5000.0

		# Raycast into world
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(_from, _to)
		var result = space_state.intersect_ray(query)

		#print(result)
		
		flare_delay.start()
		
		flare.visible = true
		flare_delay.start()
		
		
		can_shoot = false
		can_shoot_delay.start()
		
		animateShoot()
		
		flare.dissapear()
		
		if result:
			var hit_node = result.collider
			if hit_node is Player:
				return
			if hit_node.get_parent() is TrackSegment:
				return
			
			hit_node.get_parent().queue_free()
			# Example: spawn something as a child of the hit object
			#var decal = hole_scene.instantiate()
			#hit_node.add_child(decal)
			
			#decal.look_at(result.position + result.normal, Vector3.UP)
			# place it at the hit point (in local coords of hit_node)
			#decal.global_position = result.position
		
func animateShoot():
	var tween := create_tween()
	tween.tween_property(shotgun, "position", shotgun_base_position + Vector3(0, -0.2, 0), 0.2)
	tween.tween_property(shotgun, "position", shotgun_base_position, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_timer_timeout():
	flare.visible = false

func _reset_can_shoot():
	can_shoot = true
