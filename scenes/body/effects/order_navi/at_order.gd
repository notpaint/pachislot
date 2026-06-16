extends Node

@onready var effects = $"../.."

var mode_data: Dictionary = {}
var premonition_map: Dictionary = {}

var current_mode: String
var next_bonus: int

func _ready():
    mode_data = sub.mode_data
    premonition_map = sub.premonition_map

    if effects:
        if effects.has_signal("main_flag"):
            effects.main_flag.connect(_on_main_flag)


func _on_main_flag(value):
    if not current_mode and not next_bonus:
        morning_game()


func morning_game():
    var mode_weights = {"A": 70, "B": 25, "C": 1, "Heaven": 4}
    var mode = drawing(mode_weights)
    current_mode = mode

    var game_weight = mode_data[current_mode]["release"]




func drawing(weight_dict):
    var rand_num = randi() % 100

    for key in weight_dict.keys():
        var weight = weight_dict[key]
        rand_num -= weight
        if rand_num < 0:
            return(key)