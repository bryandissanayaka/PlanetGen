extends Control

@onready var planet = %Planet
@onready var env = $"../WorldEnvironment"

@onready var rotation_label = %RotationLabel
@onready var rotation_slider = %RotationSlider

@onready var frequency_slider = %FrequencySlider
@onready var frequency_label = %FrequencyLabel

@onready var octaves_label = %OctavesLabel
@onready var octaves_slider = %OctavesSlider

@onready var lacunarity_label = %LacunarityLabel
@onready var lacunarity_slider = %LacunaritySlider


const BLUE_NEBULAE = preload("res://backgrounds/blue_nebulae_1.png")
const HAZY_NEBULAE = preload("res://backgrounds/hazy_nebulae_1.png")
const PLAIN_STARFIELD = preload("res://backgrounds/plain_starfield_1.png")
const RINGED_PLANET = preload("res://backgrounds/ringed_gas_giant_planet.png")

var defaults: Dictionary

var color1
var color2
var color3
var color4

func _ready():
	reset_labels()	
	defaults["rotation"] = planet.rotation_speed
	defaults["frequency"] = planet.noise.frequency
	defaults["octaves"] = planet.noise.fractal_octaves
	defaults["lacunarity"] = planet.noise.fractal_lacunarity
	
	var colours = planet.terrain_material.get_shader_parameter("gradient").gradient.colors
	color1 = colours[0]
	color2 = colours[1]
	color3 = colours[2]
	color4 = colours[3]
	reset_colours()

func reset_labels():
	rotation_label.text = "Rotation: " + str(snappedf(planet.rotation_speed, 0.01))
	rotation_slider.value = planet.rotation_speed
	frequency_label.text = "Frequency: " + str(snappedf(planet.noise.frequency, 0.01))
	frequency_slider.value = planet.noise.frequency
	octaves_label.text = "Octaves: " + str(planet.noise.fractal_octaves)
	octaves_slider.value = planet.noise.fractal_octaves
	lacunarity_label.text = "Lacunarity: " + str(planet.noise.fractal_lacunarity)
	lacunarity_slider.value = planet.noise.fractal_lacunarity

func _on_rotation_slider_value_changed(value):
	rotation_label.text = "Rotation: " + str(snappedf(rotation_slider.value, 0.01))
	planet.rotation_speed = rotation_slider.value

func _on_stop_button_pressed():
	rotation_label.text = "Rotation: " + str(0.0)
	rotation_slider.value = 0.0
	planet.rotation_speed = 0.0

func _on_background_menu_item_selected(index):
	match index:
		0:
			env.environment.sky.sky_material.panorama = BLUE_NEBULAE
		1:
			env.environment.sky.sky_material.panorama = HAZY_NEBULAE
		2:
			env.environment.sky.sky_material.panorama = RINGED_PLANET
			env.environment.sky_rotation.y = 2.61799

func _on_frequency_slider_drag_ended(value_changed):
	if value_changed:
		frequency_label.text = "Frequency: " + str(snappedf(frequency_slider.value, 0.01))
		planet.noise.frequency = frequency_slider.value
		planet.generate(false)

func _on_octaves_slider_drag_ended(value_changed):
	if value_changed:
		octaves_label.text = "Octaves: " + str(int(octaves_slider.value))
		planet.noise.fractal_octaves = octaves_slider.value
		planet.generate(false)

func _on_lacunarity_slider_drag_ended(value_changed):
	if value_changed:
		lacunarity_label.text = "Lacunarity: " + str(snappedf(lacunarity_slider.value, 0.01))
		planet.noise.fractal_lacunarity = lacunarity_slider.value
		planet.generate(false)

func _on_generate_button_pressed():
	planet.generate(true)

func _on_update_button_pressed():
	planet.generate(false)
	
func _on_reset_button_pressed():
	planet.rotation_speed = defaults["rotation"]
	planet.noise.frequency = defaults["frequency"]
	planet.noise.fractal_octaves = defaults["octaves"]
	planet.noise.fractal_lacunarity = defaults["lacunarity"]
	%CameraPivot.rotation_degrees.x = 0
	%PitchSlider.value = 0
	planet._on_water_level_slider_value_changed(1.0)
	%WaterLevelSlider.value = 1.0
	planet._on_water_depth_slider_value_changed(10.5)
	%WaterDepthSlider.value = 10.5
	planet.noise.fractal_gain = 0.5
	planet.terrain_material.set_shader_parameter("height", 2.5)
	%HeightModifierSlider.value = 2.5
	reset_colours()
	planet.generate(false)
	reset_labels()

func _on_tab_right_pressed():
	%Tab0.visible = false
	%Tab1.visible = true


func _on_tab_left_pressed():
	%Tab1.visible = false
	%Tab0.visible = true


func _on_height_modifier_slider_value_changed(value):
	planet.terrain_material.set_shader_parameter("height", value)
	
	
func change_colour(colour: int, value: float, rect: ColorRect):
	var gradient: GradientTexture1D = planet.terrain_material.get_shader_parameter("gradient")
	gradient.gradient.colors[colour].h = value
	rect.color = gradient.gradient.colors[colour]
	planet.terrain_material.set_shader_parameter("gradient", gradient)

func _on_colour_1_slider_value_changed(value):
	change_colour(0, value, %Colour1Rect)

func _on_colour_2_slider_value_changed(value):
	change_colour(1, value, %Colour2Rect)

func _on_colour_3_slider_value_changed(value):
	change_colour(2, value, %Colour3Rect)

func _on_colour_4_slider_value_changed(value):
	change_colour(3, value, %Colour4Rect)
	
func reset_colours():
	var gradient: GradientTexture1D = planet.terrain_material.get_shader_parameter("gradient")
	
	gradient.gradient.colors[0] = color1
	%Colour1Rect.color = color1
	%Colour1Slider.value = color1.h
	
	gradient.gradient.colors[1] = color2
	%Colour2Rect.color = color2
	%Colour2Slider.value = color2.h
	
	gradient.gradient.colors[2] = color3
	%Colour3Rect.color = color3
	%Colour3Slider.value = color3.h
	
	gradient.gradient.colors[3] = color4
	%Colour4Rect.color = color4
	%Colour4Slider.value = color4.h
	
	planet.terrain_material.set_shader_parameter("gradient", gradient)
	pass

func _on_rand_colours_button_pressed():
	var x = randf_range(0.0, 1.0)
	_on_colour_1_slider_value_changed(x)
	%Colour1Slider.value = x
	
	x = randf_range(0.0, 1.0)
	_on_colour_2_slider_value_changed(randf_range(0.0, 1.0))
	%Colour2Slider.value = x
	
	x = randf_range(0.0, 1.0)
	_on_colour_3_slider_value_changed(randf_range(0.0, 1.0))
	%Colour3Slider.value = x
	
	x = randf_range(0.0, 1.0)
	_on_colour_4_slider_value_changed(randf_range(0.0, 1.0))
	%Colour4Slider.value = x

func _on_reset_colours_button_pressed():
	reset_colours()

func _on_option_button_item_selected(index):
	var t: GradientTexture1D = planet.terrain_material.get_shader_parameter("gradient")
	var w: GradientTexture1D = planet.water_material.get_shader_parameter("gradient")
	t.gradient.interpolation_mode = index
	w.gradient.interpolation_mode = index
	planet.terrain_material.set_shader_parameter("gradient", t)
	planet.water_material.set_shader_parameter("gradient", w)

func _on_detail_slider_value_changed(value):
	planet.detail = value
	planet.generate(false)
	%DetailLabel.text = "Detail: "+str(int(value))

func _on_save_pressed():
	var save_file = FileAccess.open("user://planet.save", FileAccess.WRITE)
	var save_dict = planet.get_data()
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)
	print(json_string)
	
func _on_import_pressed():
	if not FileAccess.file_exists("user://planet.save"):
		return
	var save_file = FileAccess.open("user://planet.save", FileAccess.READ)
	var json_string = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		return
	var data = json.data
	planet.import_data(data)
	frequency_slider.value = data["frequency"]
	frequency_label.text = "Frequency: " + str(snappedf(frequency_slider.value, 0.01))
	octaves_slider.value = data["octaves"]
	octaves_label.text = "Octaves: " + str(int(octaves_slider.value))	
	lacunarity_slider.value = data["lacunarity"]
	lacunarity_label.text = "Lacunarity: " + str(snappedf(lacunarity_slider.value, 0.01))
	%WaterLevelSlider.value = data["water_level"]
	%WaterDepthSlider.value = data["water_depth"]
	%DetailSlider.value = data["detail"]
	%DetailLabel.text = "Detail: "+str(int(%DetailSlider.value))
	%HeightModifierSlider.value = data["height_modifier"]
	%Colour1Slider.value = data["colour1"]
	%Colour2Slider.value = data["colour2"]
	%Colour3Slider.value = data["colour3"]
	%Colour4Slider.value = data["colour4"]
	var colours = planet.terrain_material.get_shader_parameter("gradient").gradient.colors
	%Colour1Rect.color = colours[0]
	%Colour2Rect.color = colours[1]
	%Colour3Rect.color = colours[2]
	%Colour4Rect.color = colours[3]
	planet._on_erosion_reset_button_pressed()
	
	
