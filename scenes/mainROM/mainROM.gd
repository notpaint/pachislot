extends Node2D

const pattern_scale : float = 215.0
const pattern_sum : int = 21
const reel_length : float = pattern_scale * pattern_sum
const pattern_per : float = 1.0 / pattern_sum
const reel_rpm : float = 80.0

var weight_table : Dictionary = {}
var flag_table : Dictionary = {}
var all_roles : Dictionary = {}
var control_table : Dictionary = {}
var vac_pattern : Dictionary = {}
var pattern_priority : Dictionary = {}
var flag_priority : Dictionary = {}
var JAC_data : Dictionary = {}
var RT_data : Dictionary = {}
var RT_pattern : Dictionary = {}
var bonus_data : Dictionary = {}
var bonus_variety : Array = ["RB1", "BB1"]

var reel_table : Array = [[],[],[]]
var current_reel : Array = [[],[],[]]
var miss_patterns: Array = []
var current_control_table : Array = []
var valid_roles : Array = []

var medal_sum : int = 1000:
	set(value):
		if medal_sum == value:
			return
		medal_sum = value
		medal_number.emit(value)

var bet_medals : int = 0:
	set(value):
		if bet_medals == value:
			return
		bet_medals = value
		medal_bet.emit(value)
		Datahub.bet_medals = value

var is_spinning = [false, false, false]
var can_stop_reel : Array = [false, false, false]

var max_spin_speed : float = (reel_rpm / 60.0) * reel_length
var acceleration : float = 6500
var current_spin_speed : Array = [0.0, 0.0, 0.0]

var active_tweens : Array[Tween] = [null, null, null]

var result_flag : String = "None": #当選フラグ
	set(value):
		if result_flag == value:
			return
		result_flag = value
		flag.emit(value)
		Datahub.result_flag = value
		
var result_roles : Array = []

var bonus_state:  #成立中ボーナス
	set(value):
		if bonus_state == value:
			return
		bonus_state = value
		bonus_est.emit(value)
		Datahub.bonus_state = value

var current_JAC : String= "None" #JAC状態

var current_RT : String = "RT0":
	set(value):
		if current_RT == value:
			return
		current_RT = value
		now_RT.emit(value)
		Datahub.bonus_state = value

var current_bonus : String = "None":
	set(value):
		if current_bonus == value:
			return
		current_bonus = value
		now_bonus.emit(value)
		Datahub.current_bonus = value

var RT_game : int = 0
var RT_level : int = 0

var JAC_game = false
var JAC_counter : Array
var max_bonus_payout : int = 0
var current_bonus_payout : int = 0

signal flag(result_flag)
signal prized(reel_result)
signal spin_start()
signal bonus_est(bonus_state)
signal now_bonus(current_bonus)
signal now_RT(current_RT)
signal medal_bet(bet_medals)
signal medal_number(medal_sum)

@onready var L_reel = $window/L_reel
@onready var C_reel = $window/C_reel
@onready var R_reel = $window/R_reel

@onready var reels = [L_reel, C_reel, R_reel]

func _ready():
	connect_to_debug()
	load_data_from_db()


#回転処理
func _process(delta: float):
	for i in range(3):
		if is_spinning[i] and (active_tweens[i] == null or not active_tweens[i].is_running()):
			current_spin_speed[i] = move_toward(current_spin_speed[i], max_spin_speed, acceleration * delta)
			reels[i].position.y += current_spin_speed[i] * delta
			if current_spin_speed[i] >= max_spin_speed:
				can_stop_reel[i] = true
			if reels[i].position.y >= reel_length:
				reels[i].position.y -= reel_length
		else:
			current_spin_speed[i] = 0.0
	

func _unhandled_input(event):
	if not event.is_pressed() or event.is_echo():
		return

	if event.is_action_pressed("lever"):
		if can_spin():
			start_spin()

	if event.is_action_pressed("maxbet"):
		maxbet()
	if event.is_action_pressed("stop_left"):
		if not result_flag == "None":
			try_stop_reel(0)
	if event.is_action_pressed("stop_center"):
		if not result_flag == "None":	
			try_stop_reel(1)
	if event.is_action_pressed("stop_right"):
		if not result_flag == "None":	
			try_stop_reel(2)

	if event.is_action_pressed("debug"):
		print_to_console()

func print_to_console():
	print(weight_table)
		
		
func start_spin():

	clear_current_data()
	generate_flag()
	generate_role_list()

	current_control_table = create_control_data(result_roles)

	for i in range (3):
		is_spinning[i] = true

	spin_start.emit()


func clear_current_data():
	current_reel = [[],[],[]]
	result_flag = "None"
	valid_roles = []
	miss_patterns = []
	result_roles = []


func can_spin():
	if is_spinning.has(true):
		return false
	if bet_medals == 0:
		return false
	return true



func generate_flag():	
	var rand_num : int = drawing()
	result_flag = select_flags(rand_num)

	if not Datahub.force_flag == "None":
		result_flag = Datahub.force_flag
		Datahub.force_flag = "None"
	
	return (result_flag)


func generate_role_list():
	if result_flag == "vac":
		if bonus_state:
			var current_est_bonus = all_roles[bonus_state]
			result_roles.append(current_est_bonus)
		return
	var result_flag_table = flag_table[result_flag]
	for role in result_flag_table:
		var role_name = role["role"]
		if role_name in bonus_variety:
			if not bonus_state:
				if bonus_data[role_name]["before_RT"]:
					start_RT(bonus_data[role_name]["before_RT"])
				bonus_state = role_name
				continue
			if bonus_state:
				continue
		result_roles.append(role)
	
	if bonus_state:
		var current_est_bonus = all_roles[bonus_state]
		result_roles.append(current_est_bonus)


func maxbet():
	if not is_spinning[0] and not is_spinning[1] and not is_spinning[2]:
		if current_JAC != "None":
			if bet_medals != 0:
				return
			var play_bet = JAC_data[current_JAC]["bet"]
			if medal_sum < play_bet:
				return
			bet_medals = play_bet
			medal_sum = medal_sum - bet_medals
			return
		if bet_medals == 3:
			return
		if medal_sum < 3:
			return
		medal_sum = medal_sum - 3
		bet_medals = 3

func _on_maxbet_requested():
	maxbet()

func _on_lever_requested():
	if can_spin():
		start_spin()

func _on_stop_requested(reel_pos):
	try_stop_reel(reel_pos)

func _on_debug_requested():
	print_to_console()


func try_stop_reel(reel_pos):
	if not can_stop_reel[reel_pos]:
		return
	if not is_spinning[reel_pos]:
		return
	if active_tweens[reel_pos]:
		return
	var reel = reels[reel_pos]
	var current_pixel = reel.position.y
	var raw_ID = get_raw_ID(current_pixel)
	var base_ID = posmod(raw_ID, pattern_sum)
	var slide = 0
	var supposed_symbols : Array = get_supposed_symbols(base_ID, reel_pos)

	if is_spinning[0] and is_spinning[1] and is_spinning[2]:
		if result_roles.is_empty():
			slide = current_control_table[0]["slide"][reel_pos][base_ID]
			var target_ID = posmod(raw_ID + slide, pattern_sum)
			current_reel[reel_pos] = reel_table[reel_pos][target_ID]
			stop_reels(slide,current_pixel ,raw_ID ,reel_pos)
		else:
			slide = table_logic(
				supposed_symbols, current_control_table, reel_pos, base_ID
				)
			var target_ID = posmod(raw_ID + slide, pattern_sum)
			current_reel[reel_pos] = reel_table[reel_pos][target_ID]
			stop_reels(slide,current_pixel ,raw_ID ,reel_pos)
	else:
		if result_roles.is_empty():
			slide = vac_control_logic(supposed_symbols, reel_pos)
			var target_ID = posmod(raw_ID + slide, pattern_sum)
			current_reel[reel_pos] = reel_table[reel_pos][target_ID]
			stop_reels(slide,current_pixel ,raw_ID ,reel_pos)
		else:
			slide = control_logic(
				supposed_symbols, valid_roles, reel_pos
				)
			var target_ID = posmod(raw_ID + slide, pattern_sum)
			current_reel[reel_pos] = reel_table[reel_pos][target_ID]
			stop_reels(slide,current_pixel ,raw_ID ,reel_pos)


func get_supposed_symbols(base_ID, reel_pos):
	var supposed_symbols : Array = []
	for i in range(5):
		var target_ID = (base_ID + i) % pattern_sum
		var supposed_symbol = reel_table[reel_pos][target_ID]
		var data = {
			"slide" : i,
			"target_ID" : target_ID,
			"symbol" : supposed_symbol,
			"kind" : 0,
			"combo" : 0,
			"payout" : 0,
			"priority" : 0,
			"count_roles" : []
		}
		supposed_symbols.append(data)
	return(supposed_symbols)


func scoring_symbols(supposed_symbol_data, kind, payout, priority, role):
	
	if not role in supposed_symbol_data["count_roles"]:
		supposed_symbol_data["count_roles"].append(role)
		supposed_symbol_data["combo"] += 1

	if supposed_symbol_data["kind"] > kind:
		return

	supposed_symbol_data["kind"] = kind

	if supposed_symbol_data["payout"] < payout:
		supposed_symbol_data["payout"] = payout

	var current_priority = supposed_symbol_data["priority"]
	supposed_symbol_data["priority"] = max(current_priority, priority)
	

func table_logic(supposed_symbols, control_data, reel_pos, base_ID):
	valid_roles.clear()

	for row in control_data:
		var role = row["role"]
		var slide = row["slide"][reel_pos][base_ID]
		var kind = row["kind"]
		var payout = row["payout"]
		var pattern_list = row["pattern"]
		var priority = 0

		var supposed_symbol_data = supposed_symbols[slide]
		var supposed_symbol = supposed_symbol_data["symbol"]

		for valid_pattern in pattern_list:
			var target_symbol = valid_pattern[reel_pos]
			if target_symbol == supposed_symbol:
				scoring_symbols(supposed_symbol_data, kind, payout, priority, role)
				var pattern = valid_pattern
				var data = {
					"role": role,
					"pattern" : pattern,
					"kind" : kind,
					"payout": payout
				}
				valid_roles.append(data)
		
	if not valid_roles.is_empty():
		var type = 0
		if flag_priority.has(result_flag):
			if bonus_state and flag_priority[result_flag].has(bonus_state):
				type = flag_priority[result_flag][bonus_state][reel_pos]
			else:
				type = flag_priority[result_flag]["default"][reel_pos]
		print("押したリール:{reel_pos}")
		for s in supposed_symbols:
			print("symbol:%s, Combo:%d, Payout:%d" % [s["symbol"], s["combo"], s["payout"]])
		supposed_symbols.sort_custom(sorting_symbols.bind(type))
		return(supposed_symbols[0]["slide"])
	
	var miss_slides : Array = []
	for row in control_data:
		var ghost_patterns = row["miss_pattern"]
		for miss_pattern in ghost_patterns:
			for i in (supposed_symbols.size()):
				var supposed_data = supposed_symbols[i]
				if supposed_data["symbol"] == miss_pattern[reel_pos]:
					miss_slides.append(i)
					miss_patterns.append(miss_pattern)

	if not miss_slides.is_empty():
		miss_slides.sort()
		return(miss_slides[0])

	return(4)


func control_logic(supposed_symbols, valid_role, reel_pos):
	if not valid_role.is_empty():
		var current_valid_roles : Array = []
		for row in valid_role:
			# print(row)
			var role = row["role"]
			var kind = row["kind"]
			var payout = row["payout"]
			var valid_pattern = row["pattern"]
			var valid_symbol = valid_pattern[reel_pos]
			for i in (supposed_symbols.size()):
				var supposed_symbol_data = supposed_symbols[i]
				var target_ID = supposed_symbol_data["target_ID"]
				if supposed_symbol_data["symbol"] == valid_symbol:
					var priority = get_pattern_priority(role, reel_pos, target_ID, "valid")
					scoring_symbols(supposed_symbol_data, kind, payout, priority, role)
					var data = {
						"role": role,
						"pattern": valid_pattern,
						"kind": kind,
						"payout": payout,
						"priority": priority
					}
					current_valid_roles.append(data)


		if not current_valid_roles.is_empty():
			valid_roles = current_valid_roles
			var type = 0
			if flag_priority.has(result_flag):
				if bonus_state and flag_priority[result_flag].has(bonus_state):
					type = flag_priority[result_flag][bonus_state][reel_pos]
				else:
					type = flag_priority[result_flag]["default"][reel_pos]
			print("押したリール:%d" %reel_pos)
			for s in supposed_symbols:
				print("symbol:%s, Combo:%d, Payout:%d" % [s["symbol"], s["combo"], s["payout"]])
			supposed_symbols.sort_custom(sorting_symbols.bind(type))
			# print(supposed_symbols)
			return(supposed_symbols[0]["slide"])


		valid_roles = []
		var ghosts : Array = []
		for row in valid_role:
			var role = row["role"]
			var miss = all_roles[role]["miss_pattern"]
			if miss:
				for pattern in miss:
					ghosts.append(pattern)
		if not ghosts.is_empty():
			return(miss_route(supposed_symbols, ghosts, reel_pos))
	
	if not miss_patterns.is_empty():
		return(miss_route(supposed_symbols, miss_patterns, reel_pos))

	return(dodge_invalid_role(supposed_symbols, reel_pos))
	
	
func miss_route(supposed_symbols, ghosts, reel_pos):
	var miss_slides : Array = []
	var current_miss_patterns : Array = []
	for miss_pattern in ghosts:
		var miss_symbol = miss_pattern[reel_pos]
		for i in (supposed_symbols.size()):
			var supposed_data = supposed_symbols[i]
			if supposed_data["symbol"] == miss_symbol:
				miss_slides.append(i)
				current_miss_patterns.append(miss_pattern)
	if not current_miss_patterns.is_empty():
		miss_patterns = current_miss_patterns
		return(miss_slides[0])
	
	return(dodge_invalid_role(supposed_symbols, reel_pos))


func dodge_invalid_role(supposed_symbols, reel_pos):
	print("dodge")
	for i in range(supposed_symbols.size()):
		var safe = true
		var supposed_symbol = supposed_symbols[i]["symbol"]
		for role in all_roles:
			var role_patterns = all_roles[role]["pattern"]
			for role_pattern in role_patterns:
				if supposed_symbol != role_pattern[reel_pos]:
					continue
				var matched = true
				for j in range(3):
					if j != reel_pos and not current_reel[j].is_empty():
						if role_pattern[j] != current_reel[j]:
							matched = false
							break
				if matched:
					safe = false
					break
			if not safe:
				break
		if safe:
			return(i)
	return(4)


func get_pattern_priority(role, reel_pos, target_ID, route):
	if not pattern_priority.has(role):
		return 0
	
	var state = bonus_state
	if state == null or not pattern_priority[role].has(bonus_state):
		state = "default"
	
	if not pattern_priority[role].has(state):
		return 0
	if not pattern_priority[role][state].has(reel_pos):
		return 0
	if not pattern_priority[role][state][reel_pos].has(route):
		return 0
	if not pattern_priority[role][state][reel_pos][route].has(target_ID):
		return 0

	var priority = pattern_priority[role][state][reel_pos][route][target_ID]
	return priority

func sorting_symbols(x, y, type):
	if x["kind"] != y["kind"]:
		return x["kind"] > y["kind"]
	if type == 1:
		if x["combo"] != y["combo"]:
			return x["combo"] > y["combo"]
		if x["payout"] != y ["payout"]:
			return x["payout"] > y["payout"]
	else:
		if x["payout"] != y ["payout"]:
			return x["payout"] > y["payout"]
		if x["combo"] != y["combo"]:
			return x["combo"] > y["combo"]
	if x["priority"] != y["priority"]:
		return x["priority"] > y["priority"]
	return x["slide"] < y["slide"]

func vac_control_logic(supposed_symbols, reel_pos):
	var patterns = vac_pattern.get("pattern", [])
	for i in (supposed_symbols.size()):
		var supposed_symbol = supposed_symbols[i]["symbol"]
		var slide = supposed_symbols[i]["slide"]

		for pattern in patterns:
			if pattern[reel_pos] != supposed_symbol:
				continue
			var matched = true
			for j in range(3):
				if j == reel_pos:
					continue
				if not current_reel[j].is_empty() and pattern[j] != current_reel[j]:
					matched = false
					break
			
			if matched:
				return slide
	
	return 4
			

	


#フラグデータ読み込み
func load_data_from_db():
	weight_table = Database.weight_table
	flag_table = Database.flag_table
	all_roles = Database.all_roles
	control_table = Database.control_table
	vac_pattern = Database.vac_pattern
	pattern_priority = Database.pattern_priority
	flag_priority = Database.flag_priority
	JAC_data = Database.JAC_data
	RT_data = Database.RT_data
	RT_pattern = Database.RT_pattern
	bonus_data = Database.bonus_data
	reel_table = Database.reel_table

#デバッグデータベース接続
func connect_to_debug():
	Datahub.maxbet_requested.connect(_on_maxbet_requested)
	Datahub.lever_requested.connect(_on_lever_requested)
	Datahub.stop_requested.connect(_on_stop_requested)
	Datahub.debug_requested.connect(_on_debug_requested)


#フラグ抽選
func select_flags(value):

	if not weight_table.has(current_JAC):
		print("error : bonus_state %s not found" % current_JAC)
		return "vac"
	var current_RT_table = weight_table[current_JAC]


	if not current_RT_table.has(current_RT):
		print("error : RT_state %s not found" % current_RT)
		return "vac"
	var current_bet_table = current_RT_table[current_RT]

	if not current_bet_table.has(bet_medals):
		return "vac"

	var current_weight_table = current_bet_table[bet_medals]
	for data in current_weight_table:
		var weight = int(data["weight"])
		value -= weight
		if value < 0:
			return(data["flag"])
	return("vac")



#乱数生成
func drawing():
	var loop_duration : int = 65536 * 2
	var current_time = Time.get_ticks_usec()
	var current_value: float = current_time % loop_duration
	var result_value = int(current_value / 2)
	return(result_value)


#当選役の制御テーブル作成
func create_control_data(result_role):
	var control_data = []
	var i = 0

	if result_role.is_empty():
		var vac_data : Dictionary
		vac_data["slide"] = control_table["vac"]
		vac_data["payout"] = 0
		control_data.append(vac_data)
	else:
		for row in result_role:
			i += 1
			var role = row["role"]
			var payout = row["payout"]
			var kind = row["kind"]
			var pattern = row["pattern"]
			var miss_pattern = row["miss_pattern"]
			var slide = control_table[role]
			var role_data : Dictionary
			role_data["role"] = role 
			role_data["payout"] = payout
			role_data["kind"] = kind
			role_data["slide"] = slide
			role_data["miss_pattern"] = miss_pattern
			role_data["pattern"] = pattern
			role_data["priority"] = i
			control_data.append(role_data)

	return(control_data)


func get_raw_ID(pixel):
	var raw_current_scale = pixel / pattern_scale
	var raw_ID = int(ceil(raw_current_scale))
	return (raw_ID)


#リール停止処理
func stop_reels(slide, current_pixel, raw_ID, reel_pos):

	# is_spinning[reel_pos] = false

	var reel = reels[reel_pos]
	var target_pixel = raw_ID * pattern_scale

	# print(slide)

	target_pixel += (slide * pattern_scale)
	var target_speed : float = abs(target_pixel - current_pixel) / current_spin_speed[reel_pos]
	active_tweens[reel_pos] = create_tween()
	active_tweens[reel_pos].tween_property(reel, "position:y" , target_pixel, target_speed)
	active_tweens[reel_pos].tween_callback(func():
		is_spinning[reel_pos] = false
		can_stop_reel[reel_pos] = false
		active_tweens[reel_pos] = null
		)
	await active_tweens[reel_pos].finished

	reel.position.y = fmod(reel.position.y, reel_length)

	if active_tweens[reel_pos]:
		active_tweens[reel_pos].kill()
	
	if not is_spinning[0] and not is_spinning[1] and not is_spinning[2]:
		while Input.is_anything_pressed():
			await get_tree().process_frame
	
		check_prize()


func check_prize():

	bet_medals = 0

	if JAC_game:
		JAC_counter[1] -= 1

	if not JAC_game and RT_game != 0:
		RT_game -= 1
		if RT_game <= 0:
			end_RT()

	var reel_result : Array = get_reel_result()

	var matched_role = get_matched_role(reel_result)

	get_matched_RT_pattern(reel_result)

	if matched_role:
		role_prize(matched_role)

	if JAC_game:
		print(JAC_counter)
		if JAC_counter[0] <= 0 or JAC_counter[1] <= 0:
			end_JAC()

	if current_bonus != "None" and max_bonus_payout > 0:
		if current_bonus_payout >= max_bonus_payout:
			end_bonus()
	
	prized.emit(reel_result)


func role_prize(matched_role):
	var role = matched_role["name"]
	var payout = matched_role["payout"]
	var kind = matched_role["kind"]

	medal_sum += payout

	if current_bonus != "None" and max_bonus_payout > 0:
		current_bonus_payout += payout

	if JAC_game:
		JAC_counter[0] -= 1

	match kind:
		1: #ボーナス
			if bonus_data.has(role):
				start_bonus(role)
			else:
				pass
		2: #小役
			pass
		3: #リプレイ
			bet_medals = 3




func get_matched_role(reel_result):
	for role in all_roles:
		var role_data = all_roles[role]
		var patterns = role_data["pattern"]
		for pattern in patterns:
			if reel_result == pattern:
				var data = {
					"name" : role,
					"payout" : role_data["payout"],
					"kind" : role_data["kind"],
					"pattern" : role_data["pattern"]
				}
				return (data)

func get_matched_RT_pattern(reel_result):
	for RT_name in RT_pattern:
		var patterns = RT_pattern[RT_name]
		for pattern in patterns:
			if reel_result == pattern:
				start_RT(RT_name)


func get_reel_result():
	var reel_result : Array = [[], [], []]
	for i in range(3):
		var reel = reels[i]
		var current_pixel = reel.position.y
		var raw_ID = get_raw_ID(current_pixel)
		var base_ID = posmod(raw_ID, pattern_sum)
		reel_result[i] = reel_table[i][base_ID]
	return (reel_result)


func start_bonus(role):
	var data = bonus_data[role]
	var JACIN_type = data["JACIN_type"]
	var max_payout = data["max_payout"]
	bonus_state = null
	current_bonus = role

	if not max_payout:
		start_JAC(JACIN_type)
		return
	
	if JACIN_type:
		max_bonus_payout = max_payout
		current_bonus_payout = 0
		start_JAC(JACIN_type)
	else:
		max_bonus_payout = max_payout
		current_bonus_payout = 0
		current_bonus = role



func start_JAC(JAC):
	current_RT = "RT0"
	print("JAC_IN")
	JAC_game = true
	JAC_counter = JAC_data[JAC]["counter"].duplicate()
	current_JAC = JAC


func end_JAC():
	JAC_game = false
	JAC_counter = [0,0]
	# var present_JAC = current_JAC
	current_JAC = "None"
	print("JAC_END")

	if current_bonus != "None" and max_bonus_payout > 0:
		# current_JAC = present_JAC
		var JACIN_type = bonus_data[current_bonus]["JACIN_type"]
		if JACIN_type:
			print("AUTO_JACIN")
			start_JAC(JACIN_type)
		else:
			pass

	elif current_bonus != "None":
		end_bonus()


func end_bonus():
	JAC_game = false
	JAC_counter = [0, 0]
	var after_RT = bonus_data[current_bonus]["after_RT"]
	if after_RT:
		start_RT(after_RT)
	
	print("%s IS END" % [current_bonus])
	current_bonus = "None"
	current_JAC = "None"
	max_bonus_payout = 0
	current_bonus_payout = 0


func start_RT(RT):
	if bonus_state:
		return
	var RT_type = RT_data[RT]["type"]
	# if RT_level > RT_type:
	# 	return
	RT_game = 0
	RT_level = RT_type
	current_RT = RT
	var game = RT_data[RT]["game"]
	if game:
		RT_game = game
		print(game)
	pass


func end_RT():
	RT_level = 0
	current_RT = "RT0"
