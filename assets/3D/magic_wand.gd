extends Node3D

signal done_shooting

@export var wind_up_duration:float = 0.5
@export var wind_down_duration:float = 0.5
@export var wind_up_top_angle:float = 65.0
@export var wind_bottom_top_angle:float = 40.0



func shoot():
	var tween:Tween = create_tween()
	
	tween.tween_property(self, "rotation_degrees:x", wind_up_top_angle, wind_up_duration)
	tween.tween_property(self, "rotation_degrees:x", wind_bottom_top_angle, 0.4)
	
	tween.finished.connect(done_shooting.emit)
