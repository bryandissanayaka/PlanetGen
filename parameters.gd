extends Control

@onready var rotation_label = %RotationLabel
@onready var rotation_slider = %RotationSlider

@onready var planet = %Planet


func _ready():
	rotation_label.text = "Rotation: " + str(snappedf(planet.rotation_speed, 0.01))
	rotation_slider.value = planet.rotation_speed
	pass

func update_planet():
	planet.generate()
	pass



func _on_generate_button_pressed():
	planet.noise.seed = randi()
	update_planet()


func _on_rotation_slider_value_changed(value):
	rotation_label.text = "Rotation: " + str(snappedf(rotation_slider.value, 0.01))
	planet.rotation_speed = rotation_slider.value
