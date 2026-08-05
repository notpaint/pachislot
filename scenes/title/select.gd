extends Control

@onready var A = $"list/A"
@onready var AT = $"list/AT"
@onready var A_RT = $"list/A_RT"
@onready var A_ART  = $"list/A_ART"

@onready var highres = $"resolution/1080p"
@onready var lowres = $"resolution/720p"

var loading = false

func _ready():
	A.pressed.connect(_on_A_pressed)
	AT.pressed.connect(_on_AT_pressed)
	A_RT.pressed.connect(_on_A_RT_pressed)
	A_ART.pressed.connect(_on_A_ART_pressed)
	highres.pressed.connect(_on_highres_pressed)
	lowres.pressed.connect(_on_lowres_pressed)

	get_window().content_scale_size = Vector2i(1920, 1080)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP

	get_resolution()


func _on_A_pressed():
	if loading:
		return
	loading = true
	main.load_db("A")
	get_tree().change_scene_to_file("res://scenes/body/body.tscn")

func _on_AT_pressed():
	if loading:
		return
	loading = true
	main.load_db("AT")
	get_tree().change_scene_to_file("res://scenes/body/body.tscn")

func _on_A_RT_pressed():
	if loading:
		return
	loading = true
	main.load_db("A+RT")
	get_tree().change_scene_to_file("res://scenes/body/body.tscn")

func _on_A_ART_pressed():
	if loading:
		return
	loading = true
	main.load_db("A+ART")
	get_tree().change_scene_to_file("res://scenes/body/body.tscn")

func _on_highres_pressed():
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	# get_window().move_to_center()

func _on_lowres_pressed():
	DisplayServer.window_set_size(Vector2i(1280, 720))
	# get_window().move_to_center()

func get_resolution():
	var resolution = DisplayServer.window_get_size()
	print(resolution)
