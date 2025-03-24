extends Node3D

@export var radius := 10.0 # > 0.0
@export var detail := 64
@export var noise := FastNoiseLite.new()
@export var height := 1.0 # > 0.0
@export var rotation_speed := 0.5
@export_range(0.0, 1.0, 0.0001) var water_level := 0.0 #0 to 1
@export var water_detail := 64
@export var terrain_material: Material:
	set(n):
		terrain_material = n
		if terrain_mesh.get_surface_count():
			terrain_mesh.surface_set_material(0, terrain_material)
@export var water_material: Material:
	set(n):
		water_material = n
		if water_mesh.get_surface_count():
			water_mesh.surface_set_material(0, water_material)
var terrain_mesh := ArrayMesh.new()
var water_mesh := ArrayMesh.new()


func _ready():	
	$Terrain.mesh = terrain_mesh
	$Water.mesh = water_mesh
	generate()

func generate():
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
	

func generate_terrain():
	var mesh_arrays := generate_sphere(radius, detail)
	
	var vertices: PackedVector3Array = mesh_arrays[ArrayMesh.ARRAY_VERTEX]
	for i in vertices.size():
		var vertex := vertices[i]
		vertex += vertex.normalized() * get_noise(vertex)
		vertices[i] = vertex
	
	terrain_mesh.clear_surfaces()
	terrain_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	
	terrain_mesh.surface_set_material(0, terrain_material)
	
func get_noise(vertex: Vector3) -> float:
	return (noise.get_noise_3dv(vertex.normalized() * 2.0) + 1.0) / 2.0 * height

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
