extends Node3D

@export var radius := 10.0 # > 0.0
@export var detail := 64
@export var noise := FastNoiseLite.new()
@export var height := 2.5 # > 0.0
@export var rotation_speed := 0.1
@export_range(0.0, 1.0, 0.0001) var water_level := 0.5 #0 to 1
@export var water_detail := 64
@export var terrain_material: ShaderMaterial:
	set(n):
		terrain_material = n
		if terrain_mesh.get_surface_count():
			terrain_mesh.surface_set_material(0, terrain_material)
@export var water_material: ShaderMaterial:
	set(n):
		water_material = n
		if water_mesh.get_surface_count():
			water_mesh.surface_set_material(0, water_material)
var terrain_mesh := ArrayMesh.new()
var water_mesh := ArrayMesh.new()


func _ready():	
	$Terrain.mesh = terrain_mesh
	$Water.mesh = water_mesh
	generate(true)

func generate(randomise: bool):
	if randomise:
		noise.seed = randi()
	generate_terrain()
	generate_water()
	pass

func generate_sphere(r, d) -> Array:
	var sphere := SphereMesh.new()
	sphere.radius = r
	sphere.height = r * 2
	sphere.rings = d
	sphere.radial_segments = d * 2
	return sphere.get_mesh_arrays()
	
func get_noise(vertex: Vector3) -> float:
	return (noise.get_noise_3dv(vertex.normalized() * 2.0) + 1.0) / 2.0 * height

func generate_terrain():
	var mesh_arrays := generate_sphere(radius, detail)
	
	var vertices: PackedVector3Array = mesh_arrays[ArrayMesh.ARRAY_VERTEX]
	for i in vertices.size():
		var vertex := vertices[i]
		vertex += vertex.normalized() * (get_noise(vertex) ** 1)
		vertices[i] = vertex
	
	terrain_mesh.clear_surfaces()
	terrain_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	terrain_mesh.surface_set_material(0, terrain_material)
	

func generate_water():
	if water_level == 0.0:
		$Water.visible = false
		return
	$Water.visible = true
	var water_radius := lerpf(radius, radius + height, water_level)
	var mesh_arrays := generate_sphere(water_radius, water_detail)
	water_mesh.clear_surfaces()
	water_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)	
	
	water_mesh.surface_set_material(0, water_material)
func _process(delta):
	rotate_y(delta * rotation_speed)








# should move these to parameters.gd

func _on_water_level_slider_value_changed(value):
	$Water.scale = Vector3.ONE * value


func _on_water_depth_slider_value_changed(value):
	water_material.set_shader_parameter("level", value)


func _on_erosion_advance_button_pressed() -> bool:
	if noise.fractal_gain > 0.2:
		noise.fractal_gain -= 0.025
		var h = terrain_material.get_shader_parameter("height") + 0.05
		terrain_material.set_shader_parameter("height", h)
		generate(false)
		return true
	return false


func _on_erosion_reset_button_pressed():
	noise.fractal_gain = 0.5
	terrain_material.set_shader_parameter("height", 2.5)
	generate(false)


func _on_erosion_simulate_button_pressed():
	%ErosionAdvanceButton.disabled = true
	%ErosionSimulateButton.disabled = true
	%ErosionResetButton.disabled = true
	if _on_erosion_advance_button_pressed():
		%HeightModifierSlider.value = terrain_material.get_shader_parameter("height")
		await get_tree().create_timer(0.25).timeout
		_on_erosion_simulate_button_pressed()
	else:
		%ErosionAdvanceButton.disabled = false
		%ErosionSimulateButton.disabled = false
		%ErosionResetButton.disabled = false
