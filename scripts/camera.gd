extends Node3D
@onready var env = $"../WorldEnvironment"
@onready var panel = $"../Parameters/Panel"
@onready var camera = $Camera3D

var target_pitch := 0.0
var target_fov := 60.0

func _ready():
	#panel.position.x = -1600.0
	pass

func _process(delta):
	env.environment.sky_rotation.y += delta * 0.0125
	#camera.rotation.x = lerpf(rotation.x, 0.0, delta * 2)
	#panel.position.x = lerpf(panel.position.x, -32.0, delta * 5)
	rotation_degrees.x = lerpf(rotation_degrees.x, target_pitch, 3.5 * delta)
	
	if Input.is_action_just_pressed("zoom_in"):
		target_fov -= 5.0
	elif Input.is_action_just_pressed("zoom_out"):
		target_fov += 5.0
	target_fov = clampf(target_fov, 20, 60)
	camera.fov = lerpf(camera.fov, target_fov, 4.0 * delta)
	
	
	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()
		


func _on_pitch_slider_value_changed(value):
	#rotation_degrees.x = -value
	target_pitch = value


func _on_pitch_reset_button_pressed():
	target_pitch = 0.0
	%PitchSlider.value = 0
