extends Node

@onready var effects = $"../.."

var mode_data: Dictionary = {}
var premonition_data: Dictionary = {}

var current_mode: String = "A"
var premonition_map: Dictionary = {}
var release_game: int

func _ready():
	mode_data = sub.mode_data
	premonition_data = sub.premonition_data
	# print(premonition_map)

	if effects:
		if effects.has_signal("main_flag"):
			effects.main_flag.connect(_on_main_flag)


func _on_main_flag(value):
	if not release_game:
		drawing_release_game(current_mode)
		print(premonition_map)


func morning_game():
	var mode_weights = {"A": 70, "B": 25, "C": 1, "Heaven": 4}

	var game_weight = mode_data[current_mode]["release"]


func drawing_mode(mode):
	var rand_num = effects.effects_rands[0]
	var map_dict = mode_data[mode]["map"]

	for key in map_dict.keys():
		var weight = map_dict[key]
		rand_num -= weight
		if rand_num < 0:
			current_mode = key
			break


func bonus_release(flag):
	pass

func start_premonition(game):
	var result = premonition_map[game]
	if not result:
		pass


func drawing_release_game(mode):
	var pre_map_temp: Dictionary = {}

	var current_mode_data = mode_data[mode]
	var release_game_slot = effects.effect_slot["release_game"]
	var release_game_rand = effects.effects_rands[release_game_slot]
	for game in current_mode_data["release"].keys():
		var weight = current_mode_data["release"][game]["weight"]
		release_game_rand -= weight
		if release_game_rand < 0:
			release_game = game
			pre_map_temp[game] = {"win": true}
			break
		else:
			pre_map_temp[game] = {"win": false}

	var pre_data = premonition_data["pseudo"]["map"]["default"]
	for pre_start in pre_map_temp.keys():
		var premonition_game_slot = effects.effect_slot["premonition"]
		var premonition_game_rand = effects.effects_rands[premonition_game_slot]
		if pre_map_temp[pre_start]["win"] == true:
			for game in pre_data[true].keys():
				var weight = pre_data[true][game]
				premonition_game_rand -= weight
				if premonition_game_rand < 0:
					var start_game = pre_start - game
					premonition_map[start_game] = {"win": true, "length": game}
					break

		if pre_map_temp[pre_start]["win"] == false:
			for game in pre_data[false].keys():
				var weight = pre_data[false][game]
				premonition_game_rand -= weight
				if premonition_game_rand < 0:
					var start_game = pre_start - game
					premonition_map[start_game] = {"win": false, "length": game}
					break


func culc_premonition_map():

	pass
