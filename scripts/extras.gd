extends Control

@onready var fps = $FPS
@onready var errors = $Errors
@onready var primitives = $Primitives
@onready var vram = $VRAM

@export var preset1: StringName
@export var preset2: StringName
@export var preset3: StringName
@export var preset_bugged: StringName

func _ready():
	generate_presets()
	pass
	
func generate_presets():
	DirAccess.make_dir_absolute("user://saves")
	var presets = [
		preset1, preset2, preset3, preset_bugged
	]
	var i = 1
	for p in presets:
		var path = "user://saves/preset"+str(i)+".planet"
		var save_file = FileAccess.open(path, FileAccess.WRITE)
		#var json_string = JSON.stringify(p)
		save_file.store_line(p)
		i += 1
		

func _process(_delta):
	fps.text = "FPS: " + str(int(Engine.get_frames_per_second()))
	var bytes = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var mb = int(bytes / 1000000)
	vram.text = "VRAM: " + str(mb) + " MB"

func error_msg(msg):
	errors.text = msg
	await get_tree().create_timer(10.0).timeout
	errors.text = ""

func update_primitives():
	#primitives.text = "Vertices: [loading...]"
	await get_tree().create_timer(1.0).timeout
	primitives.text = "Vertices: "+str(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
