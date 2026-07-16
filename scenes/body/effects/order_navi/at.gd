extends Node

@onready var effects = $"../.."
@onready var order_navi = $"../../order_navi"

var mode_data: Dictionary = {}
var flag_trigger: Dictionary = {}
var premonition_data: Dictionary = {}

var current_game: int = 0
var result_flag: String

var current_mode: String = "Heaven" #A, B, C, Heaven
var premonition_map: Dictionary = {}
var premonition_array: Array = []

var fake_pre_left: int
var pre_left: int = -1:
	set(value):
		if pre_left == value:
			return
		pre_left = value
		left_pre.emit(value)

var release_game: int = -1
var pre_bonus: String = "redBB" #None, RB, redBB

var base_state: String = "AT":#normal, AT
	set(value):
		if base_state == value:
			return
		base_state = value
		base_state_update.emit(value)

var play_state: String = "bonus_waiting": #normal, AT, bonus_waiting, in_bonus
	set(value):
		if play_state == value:
			return
		play_state = value
		play_state_update.emit(value)
		_on_play_state_update(value)

var bonus_condi: String = "normal":
	set(value):
		if bonus_condi == value:
			return
		bonus_condi = value
		bonus_condi_update.emit(value)

var condi_game: int = 0
var current_bonus: String = "None" #RB, redBB

var bonus_game: int = 1:
	set(value):
		if bonus_game == value:
			return
		bonus_game = value
		bonus_left.emit(value)

var bonus_get: int = 0:
	set(value):
		if bonus_get == value:
			return
		bonus_get = value
		bonus_payout.emit(value)
		

var AT_game: int = 300:
	set(value):
		if AT_game == value:
			return
		AT_game = value
		AT_left.emit(value)

var game_condi: String = "normal" #normal, extra

var morning_mode = {"A": 102, "B": 102, "C": 26, "Heaven": 26}

var BB_game = {
	5: 256,
	60: 102,
	80: 18,
	100: 8
}

var RB_game: int = 5

signal maxbet()
signal flaged(value)

signal left_pre(value)
signal base_state_update(value)
signal play_state_update(value)
signal AT_left(value)

signal bonus_wait()

signal bonus_condi_update(value)

signal bonus_start(bonus, game)
signal bonus_left(value)
signal bonus_payout(value)
signal bonus_ended(bonus)

signal AT_start()
signal AT_ended()


func _ready():
	mode_data = sub.mode_data
	flag_trigger = sub.flag_trigger
	premonition_data = sub.premonition_data


func _on_flag(value):

	result_flag = value

	check_current_game()
		
	var flag_data = flag_trigger.get(value, null)
	
	match play_state:

		"normal":
			current_game += 1

			if release_game == -1:
				if not current_mode:
					drawing_mode("morning")
				drawing_release_game(current_mode)

			if flag_data:
				flag_bonus(flag_data)

		"bonus_waiting":
			current_game += 1

			if flag_data:
				flag_bonus(flag_data)
			hit_bonus()

		"in_bonus":
			bonus_get = max(0, bonus_get - 3)
			if bonus_game > 0:
				bonus_game -= 1
			if flag_data:
				flag_in_bonus(flag_data)

		"AT":
			current_game += 1

			if bonus_condi != "normal":
				condi_game += 1

			if release_game == -1:
				if not current_mode:
					drawing_mode("morning")
				drawing_release_game(current_mode)
			
			if flag_data:
				flag_game(flag_data)
				flag_bonus(flag_data)
				flag_condi(flag_data)

			AT_game -= 1

		"penalty":
			pass

	check_premonition()

	flaged.emit(value)

func hit_bonus():

	match pre_bonus:

		"RB":
			if result_flag == "fake_Replay" or result_flag == "r7_Replay":
				order_navi.set_navi([null, 1, null], Color.RED)
				current_bonus = "RB"
				bonus_game = RB_game

		"redBB":
			if result_flag == "r7_Replay":
				order_navi.set_navi([null, null, 1], Color.RED)
				current_bonus = "redBB"
				bonus_game = assign_BB_game()

func assign_BB_game():
	var bonus_rand = effects.get_effect_rand("BB_game")
	for game in BB_game:
		var weight = BB_game[game]
		bonus_rand -= weight
		if bonus_rand < 0:
			return game


func check_current_game():

	if fake_pre_left > 0:
		fake_pre_left -= 1

	if pre_left > 0:
		pre_left -= 1


	for game in premonition_map:
		if current_game == game:
			var length = premonition_map[game]["length"]
			var win = premonition_map[game]["win"]
			if win == true:
				assign_bonus(length, true)
			else:
				assign_bonus(length, false)


func assign_bonus(length, win: bool = false):
	var type = "fake"

	if win:
		var ratio_data = mode_data[current_mode]["ratio"]
		var assign_rand = effects.get_effect_rand("bonus_assign")

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
		var weight = int(map_dict[key])
		mode_rand -= weight
		if mode_rand < 0:
			current_mode = key
			break


func flag_bonus(flag_data):
	
	if pre_bonus != "None":
		var bonus_promo_data = flag_data.get("bonus_promo", null)
		if bonus_promo_data != null:
			flag_bonus_promo(bonus_promo_data)
		
		var mode_promo_data = flag_data.get("mode_promo", null)
		if mode_promo_data != null:
			flag_mode_promo(mode_promo_data)

		return
	
	var bonus_data = flag_data.get("bonus", null)

	if not bonus_data:
		return

	var bonus_weight = bonus_data[bonus_condi]
	var flag_release_slot = effects.effect_slot["flag_release"]
	var flag_release_rand = effects.effects_rands[flag_release_slot]

	if flag_release_rand < bonus_weight:
		print("当選")
		flag_premonition(flag_data, true)
	else:
		print("非当選")
		flag_premonition(flag_data, false)


func flag_bonus_promo(promo_data):
	var promo_slot = effects.effect_slot["bonus_promo"]
	var promo_rand = effects.effects_rands[promo_slot]

	var weight = promo_data.get(pre_bonus, 0)

	if promo_rand < weight:
		match pre_bonus:
			"RB":
				pre_bonus = "redBB"


func flag_mode_promo(promo_data):
	var promo_slot = effects.effect_slot["mode_promo"]
	var promo_rand = effects.effects_rands[promo_slot]

	var weight = promo_data.get(current_mode,0)

	if promo_rand < weight:
		match current_mode:
			"A":
				current_mode = "B"
			"B":
				current_mode = "Heaven"
			"C":
				current_mode = "Heaven"


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
			AT_game += int(add)
			print(AT_game)
			break

func flag_condi(flag_data):
	var condi_data = flag_data.get("condi_promo", null)
	var condi_rand = effects.get_effect_rand("condi")

	if not condi_data:
		if bonus_condi != "normal" and condi_game > 13:
			if condi_rand < 85:
				bonus_condi = "normal"
				condi_game = 0
		return

	var weight = condi_data.get(bonus_condi, 0)

	if condi_rand < weight:
		bonus_condi = "high"


func end_AT():
	base_state = "normal"
	play_state = "normal"
	AT_ended.emit()

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
		if base_state == "normal":
			base_state = "AT"
			AT_game += 50
		else:
			AT_game += 30



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
	var i = 0
	while i < premonition_array.size():
		var data = premonition_array[i]

		if data["type"] == "fake":
			if fake_pre_left != 0 or pre_left >= 0:
				premonition_array.remove_at(i)
				continue
			fake_pre_left = data["length"]
			premonition_array.remove_at(i)

		else:
			if pre_left >= 0:
				i += 1
				continue
			pre_left = data["length"]
			pre_bonus = data["type"]

			print("本前兆開始、前回モード:", current_mode)

			drawing_mode(current_mode)

			print("残りゲーム数:", pre_left, "ボーナス種別:", pre_bonus, "次回モード:", current_mode)

			premonition_array.remove_at(i)
			continue


func _on_stop_button(reel_pos):
	order_navi.push_navi(reel_pos)


func _on_reel_stopped(reel_pos, _stopped_reel, _current_reel_grid):
	order_navi.frame_light_off(reel_pos)


func _on_prized(value):
	var payout: int
	if value:
		payout = int(value["payout"])
	match play_state:

		"normal":
			if pre_left == 0:
				play_state = "bonus_waiting"
				pre_left = -1

		"bonus_waiting":
			if check_bonus_prized(current_bonus):
				release_game = -1
				pre_bonus = "None"
				play_state = "in_bonus"

		"in_bonus":
			bonus_get += payout
			if bonus_game <= 0:
				end_bonus()

		"AT":
			if pre_left == 0:
				play_state = "bonus_waiting"
				pre_left = -1
			if AT_game <= 0:
				end_AT()

func end_bonus():

	bonus_ended.emit(current_bonus)

	current_bonus = "None"

	if base_state == "AT":
		play_state = "AT"
	else:
		play_state = "normal"
	

func _on_maxbet_pushed():
	maxbet.emit()


func _on_play_state_update(value):

	match value:

		"bonus_waiting":
			bonus_wait.emit()
		"in_bonus":
			bonus_start.emit(current_bonus, bonus_game)
		"AT":
			AT_start.emit()


func check_bonus_prized(bonus) -> bool:
	if play_state != "bonus_waiting":
		return false
	
	match bonus:
		"RB":
			return current_bonus == "RB" and result_flag in ["fake_Replay", "r7_Replay"]
		"redBB":
			return current_bonus == "redBB" and result_flag == "r7_Replay"
		
	return false
