extends Node

@onready var effects = $"../.."

var mode_data: Dictionary = {}
var premonition_map: Dictionary = {}

var current_mode: String = "A"
var release_map: Dictionary = {}
var next_bonus: int

func _ready():
	mode_data = sub.mode_data
	premonition_map = sub.premonition_map
	# print(premonition_map)

	if effects:
		if effects.has_signal("main_flag"):
			effects.main_flag.connect(_on_main_flag)


func _on_main_flag(value):
	if not next_bonus:
		release_drawing(current_mode)
	print(release_map)
	if not current_mode and not next_bonus:
		morning_game()


func morning_game():
	var mode_weights = {"A": 70, "B": 25, "C": 1, "Heaven": 4}

	var game_weight = mode_data[current_mode]["release"]


func mode_drawing(mode):
	var rand_num = effects.effects_rands[0]
	var map_dict = mode_data[mode]["map"]

	for key in map_dict.keys():
		var weight = map_dict[key]
		rand_num -= weight
		if rand_num < 0:
			current_mode = key
			break

func release_drawing(mode):
	pass
	# var release_num = effects.effects_rands[1]
	# var premonition_num_1 = effects.effects_rands[2]
	# var premonition_num_2 = effects.effects_rands[3]
	# var release_dict = mode_data[mode]["release"]

	# for release_game in release_dict.keys():
	# 	var release_weight = release_dict[release_game]["weight"]
	# 	var premonition_chance = release_dict[release_game]["premonition"]
	# 	release_num -= release_weight
	# 	if release_num < 0:
	# 		next_bonus = release_game
	# 		var win_dict = premonition_map["pseudo"]["map"]["default"][true]
	# 		for premonition_game in win_dict.keys():
	# 			var premonition_weight = win_dict[premonition_game]
	# 			premonition_num_1 -= premonition_weight
	# 			if premonition_num_1 < 0:
	# 				var game = release_game - premonition_game
	# 				var data = {
	# 					"win": true,
	# 					"release": release_game
	# 				}
	# 				release_map[game] = data
	# 				return
	# 	if premonition_chance <= premonition_num_2:
	# 		continue
	# 	var fake_dict = premonition_map["pseudo"]["map"]["default"][false]
	# 	for premonition_game in fake_dict.keys():
	# 		var premonition_weight = fake_dict[premonition_game]
	# 		premonition_num_1 -= premonition_weight
	# 		if premonition_num_1 < 0:
	# 			var game = release_game - premonition_game
	# 			var data = {
	# 				"win": false,
	# 				"release": release_game
	# 			}
	# 			release_map[game] = data
	# 			break
