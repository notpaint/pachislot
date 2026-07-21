extends Node

@onready var effects = $"../.."
@onready var order_navi = $"../../order_navi"

var mode_data: Dictionary = {}
var flag_trigger: Dictionary = {}
var premonition_data: Dictionary = {}

var current_game: int = 0:
	set(value):
		if current_game == value:
			return
		current_game = value
		effects.count_up_game()

var result_flag: String

var current_mode: String = "Heaven": #A, B, C, Heaven
	set(value):
		if current_mode == value:
			return
		current_mode = value
		mode_update.emit(value)

var premonition_map: Dictionary = {}
var premonition_pool: Array = []

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
		

var AT_game: int = 100:
	set(value):
		if AT_game == value:
			return
		AT_game = value
		AT_left.emit(value)


var total_get: int = 300:
	set(value):
		if total_get == value:
			return
		total_get = value
		total_pay.emit(value)
		

var game_condi: String = "normal" #normal, extra

var morning_mode = {"A": 102, "B": 102, "C": 26, "Heaven": 26}

var BB_game = {
	5: 256,
	40: 128,
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

signal mode_update(value)

signal bonus_wait()

signal bonus_condi_update(value)

signal bonus_start(bonus, game)
signal bonus_left(value)
signal bonus_payout(value)
signal bonus_ended(bonus)

signal AT_start()
signal AT_left(value)
signal AT_ended()

signal total_pay(value)


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

			total_get = max(0, total_get - 3)

			if flag_data:
				flag_bonus(flag_data)
			hit_bonus()

		"in_bonus":
			bonus_get = max(0, bonus_get - 3)
			total_get = max(0, total_get - 3)

			if bonus_game > 0:
				bonus_game -= 1
			if flag_data:
				flag_in_bonus(flag_data)

		"AT":
			current_game += 1

			total_get = max(0, total_get - 3)

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

	print("ゲーム数", current_game)
	print("規定ゲーム数", release_game)

	flaged.emit(value)

func _on_stop_button(reel_pos):
	order_navi.push_navi(reel_pos)

func hit_bonus():

	match pre_bonus:

		"RB":
			if result_flag == "fake_Replay" or result_flag == "r7_Replay":
				order_navi.set_navi([null, 1, null], Color.RED)
				current_bonus = "RB"
				bonus_game = RB_game
				pre_bonus = "None"

		"redBB":
			if result_flag == "r7_Replay":
				order_navi.set_navi([null, null, 1], Color.RED)
				current_bonus = "redBB"
				bonus_game = assign_BB_game()
				pre_bonus = "None"
	

func assign_BB_game():
	var bonus_rand = effects.get_effect_rand("BB_game")
	for game in BB_game:
		var weight = BB_game[game]
		bonus_rand -= weight
		if bonus_rand < 0:
			return game


func check_current_game():

	if pre_left > 0:
		pre_left -= 1


	for game in premonition_map:
		if current_game == game:
			var length = premonition_map[game]["length"]
			var win = premonition_map[game]["win"]
			var type = draw_bonus_type(win)
			start_premonition(length, type)


func draw_bonus_type(win: bool = false) -> String:
	if not win:
		return "None"
	
	var ratio_data = mode_data[current_mode]["ratio"]
	var assign_rand = effects.get_effect_rand("bonus_assign")

	for bonus in ratio_data:
		var weight = ratio_data[bonus]
		assign_rand -= weight
		if assign_rand < 0:
			return bonus

	return "None"

func start_premonition(length: int, type: String):

	if pre_left == -1:
		pre_left = length
		pre_left = length - 1
		pre_bonus = type
		print("前兆開始 type:", type, "length:", length)
		if type != "None":
			drawing_mode(current_mode)
		return

	if type == "None":
		return
	
	if length <= pre_left:
		pre_left = length
		pre_left = length - 1
		pre_bonus = type
		drawing_mode(current_mode)
		print("フェイク前兆上書き発生")
	else:
		var data = {
			"type": type,
			"length": length - pre_left
		}
		print("本前兆当選 前兆をプール")
		print(data)
		premonition_pool.append(data)

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

	var pre_active = (pre_bonus != "None")
	var pool_active = (not premonition_pool.is_empty())

	if pre_active or pool_active:
		var is_pooled = pool_active and not pre_active

		flag_bonus_promo(flag_data, is_pooled)
		flag_mode_promo(flag_data)

		return
	
	var bonus_data = flag_data.get("bonus", null)

	if not bonus_data:
		return

	var bonus_weight = bonus_data[bonus_condi]
	
	var flag_release_rand = effects.get_effect_rand("flag_release")

	if flag_release_rand < bonus_weight:
		print("当選")
		flag_premonition(flag_data, true)
	else:
		print("非当選")
		flag_premonition(flag_data, false)


func flag_bonus_promo(flag_data, is_pooled: bool = false):

	var promo_data = flag_data.get("bonus_promo", null)

	if not promo_data:
		return

	var target_bonus: String = "None"

	if is_pooled:
		if not premonition_pool.is_empty():
			target_bonus = premonition_pool[0]["type"]
	else:
		target_bonus = pre_bonus

	if target_bonus == "None":
		return 

	var weight = promo_data.get(target_bonus, 0)
	var promo_rand = effects.get_effect_rand("bonus_promo")

	if promo_rand < weight:

		match target_bonus:
			"RB":
				target_bonus = "redBB"

	if is_pooled:
		premonition_pool[0]["type"] = target_bonus
	else:
		pre_bonus = target_bonus


func flag_mode_promo(promo_data):
	var promo_rand = effects.get_effect_rand("mode_promo")

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

		var fake_pre_rand = effects.get_effect_rand("flag_fake_pre")

		if fake_pre_rand < fake_pre_weight:
			culc_flag_pre(pre_data, false)

	else:
		culc_flag_pre(pre_data, true)


func culc_flag_pre(pre_data, win: bool = false):
	var length_data = pre_data.get(win, {})

	var flag_pre_rand = effects.get_effect_rand("flag_pre")

	for length in length_data:
		var weight = length_data[length]
		flag_pre_rand -= weight

		if flag_pre_rand < 0:
			var type = draw_bonus_type(win)
			start_premonition(length, type)
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
				print("MODE DOWN")
				bonus_condi = "normal"
				condi_game = 0
		return

	var weight = condi_data.get(bonus_condi, 0)

	if condi_rand < weight:
		if bonus_condi == "high":
			condi_game = 0
		print("MODE UP")
		bonus_condi = "high"


func end_AT():
	base_state = "normal"
	play_state = "normal"
	total_get = 0
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


func _on_reel_stopped(reel_pos, _stopped_reel, _current_reel_grid):
	order_navi.frame_light_off(reel_pos)


func _on_prized(value):
	var payout: int
	if value:
		payout = int(value["payout"])
	match play_state:

		"normal":
			if pre_left == 0:
				check_premonition_pool()

		"bonus_waiting":
			total_get += payout
			if check_bonus_prized(current_bonus):
				release_game = -1
				pre_bonus = "None"
				play_state = "in_bonus"

		"in_bonus":
			bonus_get += payout
			total_get += payout
			if bonus_game <= 0:
				end_bonus()

		"AT":
			total_get += payout
			if pre_left == 0 and pre_bonus != "None":
				check_premonition_pool()
			elif AT_game <= 0:
				end_AT()
			elif pre_left == 0:
				check_premonition_pool()

func check_premonition_pool() -> void:
	pre_left = -1
	print("前兆終了")
	if pre_bonus != "None":
		play_state = "bonus_waiting"
	else:
		if not premonition_pool.is_empty():
			var data = premonition_pool[0]

			pre_left = data["length"]
			pre_bonus = data["type"]
			drawing_mode(current_mode)
			premonition_pool.remove_at(0)

			
func end_bonus():

	bonus_ended.emit(current_bonus)

	current_bonus = "None"

	bonus_get = 0
	current_game = 0
	premonition_map.clear()

	effects.reset_game_count()

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
