extends Control

@onready var A = $"list/A"
@onready var AT = $"list/AT"

var loading = false

func _ready():
	A.pressed.connect(_on_A_pressed)
	AT.pressed.connect(_on_AT_pressed)

func _on_A_pressed():
	if loading:
		return
	loading = true
	Database.load_db("A")
	get_tree().change_scene_to_file("res://scenes/body/body.tscn")

func _on_AT_pressed():
	if loading:
		return
	loading = true
	Database.load_db("AT")
	get_tree().change_scene_to_file("res://scenes/body/body.tscn")
