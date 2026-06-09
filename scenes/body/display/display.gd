extends Node2D

var scene_path: String

func _ready():
    match sub.current_version:
        "A":
            scene_path = "res://scenes/body/display/A.tscn"
        "AT":
            scene_path = "res://scenes/body/display/AT.tscn"
        "A+RT":
            scene_path = "res://scenes/body/display/A+RT.tscn"
        _:
            print("!!! failed to load display, defaulting to display_A !!!")
            scene_path = "res://scenes/body/display/A.tscn"
    

    var display_scene = load(scene_path)
    var instance = display_scene.instantiate()
    add_child(instance)