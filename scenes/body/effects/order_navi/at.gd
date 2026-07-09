extends Node

@onready var effects = $"../.."

var mode_data: Dictionary = {}
var flag_trigger: Dictionary = {}
var premonition_data: Dictionary = {}

var current_game: int = 0
var result_flag: String

var current_mode: String = "Heaven"
var premonition_map: Dictionary = {}
var premonition_array: Array = []
var release_game: int

var current_state: String = "normal"

var bonus_condi: String = "normal"
var pre_bonus:String = "None"
var current_bonus: String = "None"

var game_condi: String = "normal"

var morning_mode = {"A": 102, "B": 102, "C": 26, "Heaven": 26}

func _ready():
	mode_data = sub.mode_data
	flag_trigger = sub.flag_trigger
	premonition_data = sub.premonition_data
	# print(premonition_map)
	print(current_game)


func _on_flag(value):
	print("--- on_flag 呼び出し --- G数: ", current_game, " 役: ", value)

	result_flag = value

	if not release_game:
		if not current_mode:
			drawing_mode("morning")
		drawing_release_game(current_mode)
		print(premonition_map)
	
	current_game += 1

	check_current_game()
		
	var flag_data = flag_trigger.get(value, null)

	if not flag_data:
		return
	
	match current_state:

		"normal":
			flag_bonus(flag_data)

		"in_bonus":
			flag_in_bonus(flag_data)

		"AT":
			flag_bonus(flag_data)
			flag_game(flag_data)

	check_premonition()


func check_current_game():
	for game in premonition_map:
		if current_game == game:
			var length = premonition_map[game]["length"]
			var win = premonition_map[game]["win"]
			if win == true:
				assign_bonus(length, true)
			else:
				pass


func assign_bonus(length, win: bool = false):
	var type = "fake"

	if win:
		var ratio_data = mode_data[current_mode]["ratio"]
		var assign_slot = effects.effect_slot["bonus_assign"]
		var assign_rand = effects.effects_rands[assign_slot]

		for bonus in ratio_data:
			var weight = ratio_data[bonus]
			assign_rand -= weight
			if assign_rand < 0:
				type = bonus
				break

	var data = {
		"length": length,
		"type": type
	}

	append_premonition(data)

func append_premonition(data):
	premonition_array.append(data)


func drawing_mode(mode):
	var mode_slot = effects.effect_slot["next_mode"]
	var mode_rand = effects.effects_rands[mode_slot]

	var map_dict: Dictionary
	if mode == "morning":
		map_dict = morning_mode
	else:
		map_dict = mode_data[mode]["map"]

	for key in map_dict.keys():
		var weight = map_dict[key]
		mode_rand -= weight
		if mode_rand < 0:
			current_mode = key
			break


func flag_bonus(flag_data):
	var bonus_data = flag_data.get("bonus", null)

	if not bonus_data:
		return

	var bonus_weight = bonus_data[bonus_condi]
	var flag_release_slot = effects.effect_slot["flag_release"]
	var flag_release_rand = effects.effects_rands[flag_release_slot]

	if flag_release_rand < bonus_weight:
		flag_premonition(flag_data, true)
	else:
		flag_premonition(flag_data, false)


func flag_premonition(flag_data, win: bool = false):
	var flag_pre_data = premonition_data["pseudo"]["flag"]
	var pre_data = flag_pre_data.get(result_flag, null)
	if pre_data == null:
		pre_data = flag_pre_data.get("default", null)

	if not win:
		var fake_pre_data = flag_data["fake_pre"]
		var fake_pre_weight = fake_pre_data.get(bonus_condi, null)
	
		if fake_pre_weight == null:
			fake_pre_weight = fake_pre_data.get("default", 0)

		var fake_pre_slot = effects.effect_slot["flag_fake_pre"]
		var fake_pre_rand = effects.effects_rands[fake_pre_slot]

		print(fake_pre_rand)
		print(fake_pre_weight)

		if fake_pre_rand < fake_pre_weight:
			culc_flag_pre(pre_data, false)

	else:
		culc_flag_pre(pre_data, true)

func culc_flag_pre(pre_data, win: bool = false):
	var length_data = pre_data.get(win, {})

	var flag_pre_slot = effects.effect_slot["flag_pre"]
	var flag_pre_rand = effects.effects_rands[flag_pre_slot]

	for length in length_data:
		var weight = length_data[length]
		flag_pre_rand -= weight

		if flag_pre_rand < 0:
			assign_bonus(length, win)
			break

func hit_flag_bonus():
	pass


func flag_game(flag_data):
	var game_data = flag_data.get("game", null)

	if not game_data:
		return
	
	var game_weight = game_data[game_condi]
	var game_slot = effects.effect_slot["game"]
	var game_rand = effects.effects_rands[game_slot]
	if game_rand < game_weight:
		flag_add(flag_data)
	else:
		print("上乗せ非当選")


func flag_add(flag_data):
	var add_data = flag_data.get("add", null)

	if not add_data:
		return

	var add_slot = effects.effect_slot["add"]
	var add_rand = effects.effects_rands[add_slot]

	for add in add_data:
		var weight = add_data[add]
		add_rand -= weight
		if add_rand < 0:
			print("上乗せ当選", add)
			break


func flag_in_bonus(flag_data):
	var in_bonus_data = flag_data.get("in_bonus", null)

	if not in_bonus_data:
		return
	
	var in_current_rand = in_bonus_data.get(current_bonus, null)

	if not in_current_rand:
		return

	var in_bonus_slot = effects.effect_slot["in_bonus"]
	var in_bonus_rand = effects.effects_rands[in_bonus_slot]

	if in_bonus_rand < in_current_rand:
		print("ボーナス突破")
	else:
		print("ボーナス非突破")



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
	var map_pre_slot = effects.effect_slot["map_pre"]
	for pre_start in pre_map_temp.keys():
		var map_pre_rand = effects.effects_rands[map_pre_slot]
		if pre_map_temp[pre_start]["win"] == true:
			for game in pre_data[true].keys():
				var weight = pre_data[true][game]
				map_pre_rand -= weight
				if map_pre_rand < 0:
					var start_game = pre_start - game
					premonition_map[start_game] = {"win": true, "length": game}
					map_pre_slot += 1
					break

		if pre_map_temp[pre_start]["win"] == false:
			for game in pre_data[false].keys():
				var weight = pre_data[false][game]
				map_pre_rand -= weight
				if map_pre_rand < 0:
					var start_game = pre_start - game
					premonition_map[start_game] = {"win": false, "length": game}
					map_pre_slot += 1
					break

func check_premonition():
	print(premonition_array)