extends Node2D

const pattern_scale : float = 128.0
const pattern_sum : int = 21
const reel_length : float = pattern_scale * pattern_sum
const pattern_per : float = 1.0 / pattern_sum
const reel_rpm : float = 80.0

var db : SQLite
var db_path = "database_v2.db"


var weight_table : Dictionary = {}
var flag_table : Dictionary = {}
var all_roles : Dictionary = {}
var control_table : Dictionary = {}
var JAC_data : Dictionary = {}
var RT_data : Dictionary = {}
var bonus_data : Dictionary = {}
var bonus_variety : Array = ["RB1", "BB1"]

var reel_table : Array = [[],[],[]]
var current_reel : Array = [[],[],[]]
var miss_patterns: Array = []
var current_control_table : Array = []
var valid_roles : Array = []

var MY = 0
var bet_medals = 0
var is_spinning = [false, false, false]

var max_spin_speed : float = (reel_rpm / 60.0) * reel_length
var acceleration : float = 2500
var current_spin_speed : Array = [0.0, 0.0, 0.0]

var active_tweens : Array[Tween] = [null, null, null]


var result_flag
var result_roles : Array = []
var bonus_state = "RB1" #成立中ボーナス
var current_state = "RT0" #フラグ状態
var RT_game : int = 0
var RT_level : int = 0

var JAC_game = false
var JAC_counter : Array
var current_bonus #作動中ボーナス
var max_bonus_payout : int = 0
var current_bonus_payout : int = 0



@onready var L_reel = $window/L_reel
@onready var C_reel = $window/C_reel
@onready var R_reel = $window/R_reel

@onready var reels = [L_reel, C_reel, R_reel]

func _ready():
	db = SQLite.new()
	db.path = db_path
	db.open_db()

	load_data_from_db()


#回転処理
func _process(delta: float):
	for i in range(3):
		if is_spinning[i] and (active_tweens[i] == null or not active_tweens[i].is_running()):
			current_spin_speed[i] = move_toward(current_spin_speed[i], max_spin_speed, acceleration * delta)
			reels[i].position.y += current_spin_speed[i] * delta
			if reels[i].position.y >= reel_length:
				reels[i].position.y -= reel_length
		else:
			current_spin_speed[i] = 0.0
	

#入力処理
func _unhandled_input(event):
	if not event.is_pressed() or event.is_echo():
		return

	if event.is_action_pressed("lever"):
		if not is_spinning[0] and not is_spinning[1] and not is_spinning[2] and not bet_medals == 0:
			current_reel = [[],[],[]]
			valid_roles = []
			miss_patterns = []
			var rand_num :int = drawing()
			result_flag = select_flags(rand_num)
			result_roles = []

			if not result_flag == "vac":
				var result_flag_table = flag_table[result_flag]
				for role in result_flag_table:
					var role_name = role["role"]
					if role_name in bonus_variety:
						if not bonus_state:
							bonus_state = role_name
							continue
						if bonus_state:
							continue
					result_roles.append(role)
			if bonus_state:
				var current_est_bonus = all_roles[bonus_state]
				result_roles.append(current_est_bonus)


			# if not result_roles.is_empty():
			# 	for role in result_roles:
			# 		print(role["role"])

			if result_flag:
				print(result_roles)
				current_control_table = create_control_data(result_roles)

				for i in range (3):
					is_spinning[i] = true
				bet_medals = 0

	if event.is_action_pressed("maxbet"):
		maxbet()
	if event.is_action_pressed("stop_left"):
		if result_flag:
			try_stop_reel(0)
	if event.is_action_pressed("stop_center"):
		if result_flag:	
			try_stop_reel(1)
	if event.is_action_pressed("stop_right"):
		if result_flag:	
			try_stop_reel(2)

	if event.is_action_pressed("debug"):
		# print(weight_table[current_state])
		# print(all_roles)
		# print(bonus_data)
		# max_bonus_payout = 2
		# print(JAC_data)
		# print(weight_table["RT1"])
		# print(RT_data)
		print(RT_game)
		print(current_state)
		

func maxbet():
	if not is_spinning[0] and not is_spinning[1] and not is_spinning[2]:
		if bet_medals == 3:
			return
		MY = MY + bet_medals
		bet_medals = 0
		MY = MY - 3
		bet_medals = 3


func try_stop_reel(reel_pos):
	var reel = reels[reel_pos]
	var current_pixel = reel.position.y
	var raw_ID = get_raw_ID(current_pixel)
	var base_ID = posmod(raw_ID, pattern_sum)
	var slide = 0
	var supposed_symbols : Array = get_supposed_symbols(base_ID, reel_pos)

	if is_spinning[0] and is_spinning[1] and is_spinning[2]:
		if result_roles.is_empty():
			slide = current_control_table[0]["slide"][reel_pos][base_ID]
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
			slide = current_control_table[0]["slide"][reel_pos][base_ID]
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
			"symbol" : supposed_symbol,
			"kind" : 0,
			"combo" : 0,
			"payout" : 0 
		}
		supposed_symbols.append(data)
	return(supposed_symbols)


func scoring_symbols(supposed_symbol_data, kind, payout):
	supposed_symbol_data["combo"] += 1

	if supposed_symbol_data["kind"] > kind:
		return

	supposed_symbol_data["kind"] = kind

	if supposed_symbol_data["payout"] < payout:
		supposed_symbol_data["payout"] = payout
	

func table_logic(supposed_symbols, control_data, reel_pos, base_ID):
	valid_roles.clear()

	for row in control_data:
		var slide = row["slide"][reel_pos][base_ID]
		var kind = row["kind"]
		var payout = row["payout"]
		var pattern_list = row["pattern"]

		var supposed_symbol_data = supposed_symbols[slide]
		var supposed_symbol = supposed_symbol_data["symbol"]

		for valid_pattern in pattern_list:
			var target_symbol = valid_pattern[reel_pos]
			if target_symbol == supposed_symbol:
				scoring_symbols(supposed_symbol_data, kind, payout)
				var pattern = valid_pattern
				var data = {
					"pattern" : pattern,
					"kind" : kind,
					"payout": payout
				}
				valid_roles.append(data)
		
	if not valid_roles.is_empty():
		supposed_symbols.sort_custom(sorting_symbols)
		print(supposed_symbols)
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
			var kind = row["kind"]
			var payout = row["payout"]
			var valid_pattern = row["pattern"]
			var valid_symbol = valid_pattern[reel_pos]
			for i in (supposed_symbols.size()):
				var supposed_symbol_data = supposed_symbols[i]
				if supposed_symbol_data["symbol"] == valid_symbol:
					scoring_symbols(supposed_symbol_data, kind, payout)
					var data = {
						"pattern": valid_pattern,
						"kind": kind,
						"payout": payout
					}
					current_valid_roles.append(data)

		if not current_valid_roles.is_empty():
			valid_roles = current_valid_roles
			supposed_symbols.sort_custom(sorting_symbols)
			return(supposed_symbols[0]["slide"])

		valid_roles = []
		return(miss_route(supposed_symbols, miss_patterns, reel_pos))
	
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



func sorting_symbols(x, y):
	if x["kind"] != y["kind"]:
		return x["kind"] > y["kind"]
	if x["combo"] != y["combo"]:
		return x["combo"] > y["combo"]
	if x["payout"] != y ["payout"]:
		return x["payout"] > y["payout"]
	return x["slide"] > y["slide"]


#フラグデータ読み込み
func load_data_from_db():

	load_weight_table()
	load_flag_table()
	load_control_table()
	load_all_roles()
	load_JAC_data()
	load_RT_data()
	load_bonus_data()
	load_reel_table()


#weight_table(フラグの確率表)作成
#{"weight_state":[{"flag", "weight"}]}
func load_weight_table():
	var order = """
	SELECT 
	f.flag,
	ws.weight_state,
	ft.weight
	FROM
	flags AS f
	JOIN
	flag_table AS ft ON ft.flag_id = f.id
	JOIN
	weight_status AS ws ON ft.weight_status_id = ws.id
	"""

	db.query(order)
	var results = db.query_result

	for row in results:
		var flag = row["flag"]
		var weight_state = row["weight_state"]
		var weight = int(row["weight"])
		if not weight_table.has(weight_state):
			weight_table[weight_state] = []
		var data = {"flag": flag, "weight": weight}
		weight_table[weight_state].append(data)


#flag_table(フラグの重複役一覧)作成
#{"flag" : [{"role", "kind", "payout", pattern}]}
func load_flag_table():
	var order = """
	SELECT
	f.flag,
	r.role, r.kind, r.payout, r.pattern, r.miss_pattern
	FROM
	flag_role_map AS fr
	JOIN
	flags AS f ON fr.flag_ID = f.id
	JOIN
	roles AS r ON fr.role_ID = r.id
	"""

	db.query(order)
	var results = db.query_result

	for row in results:
		var flag = row["flag"]
		var role = row["role"]
		var kind = row["kind"]
		var payout = int(row["payout"])
		var pattern_json = row["pattern"]
		var pattern_array = JSON.parse_string(pattern_json)
		var miss_pattern_json = row["miss_pattern"]
		var miss_pattern_array = JSON.parse_string(miss_pattern_json)
		if not flag_table.has(flag):
			flag_table[flag] = []
		var data = {"role" : role, "kind": kind, "payout": payout, "pattern": pattern_array, "miss_pattern": miss_pattern_array}
		flag_table[flag].append(data)


#全小役データ作成
func load_all_roles():
	db.query("SELECT role, payout, kind, pattern, miss_pattern FROM roles")
	var results = db.query_result

	for row in results:
		var role = row["role"]
		var payout = int(row["payout"])
		var kind = int(row["kind"])
		var pattern = JSON.parse_string(row["pattern"])
		var miss_pattern = JSON.parse_string(row["miss_pattern"])
		all_roles[role] = []
		# var data = {"payout": payout, "kind": kind, "pattern":pattern}
		# all_roles[role].append(data)
		all_roles[role] = {
			"role": role,
			"payout": payout,
			"kind": kind,
			"pattern": pattern,
			"miss_pattern": miss_pattern
		}


#control_table(制御表)作成
#{"role" : [[L],[C],[R]]}
func load_control_table():

	#はずれ(vac)制御読み込み
	db.query("SELECT reel_pos, reel_ID, slide FROM vac_control")
	var results = db.query_result

	for row in results:
		var reel_pos = int(row["reel_pos"])
		var reel_ID = int(row["reel_ID"])
		var slide = int(row["slide"])
		if not control_table.has("vac"):
			control_table["vac"] = [[],[],[]]
			for i in range(3):
				control_table["vac"][i].resize(pattern_sum)
		control_table["vac"][reel_pos][reel_ID] = slide
	
	var order = """
	SELECT
	r.role,
	s.reel_pos, s.reel_ID, s.slide
	FROM
	control_table AS s
	JOIN
	roles AS r ON s.role_ID = r.id
	"""

	db.query(order)
	results = db.query_result

	for row in results:
		var role = row["role"]
		var reel_pos = int(row["reel_pos"])
		var reel_ID = int(row["reel_ID"])
		var slide = int(row["slide"])
		if not control_table.has(role):
			control_table[role] = [[],[],[]]
			for i in range(3):
				control_table[role][i].resize(pattern_sum)
		control_table[role][reel_pos][reel_ID] = slide


func load_JAC_data():
	db.query("SELECT name, prize_count, play_count FROM JAC_data")
	var results = db.query_result

	for row in results:
		var JAC_name = row["name"]
		var prize_count = int(row["prize_count"])
		var play_count = int(row["play_count"])
		JAC_data[JAC_name] = [prize_count, play_count]

func load_RT_data():
	db.query("SELECT name, game, type FROM RT_data")
	var results = db.query_result

	for row in results:
		var RT_name = row["name"]
		var game = row["game"]
		if game:
			game = int(game)
		var type = int(row["type"])
		var data = {
			"name" : RT_name,
			"game" : game,
			"type" : type
		}
		RT_data[RT_name] = data


#ボーナスデータ読み込み
func load_bonus_data():
	db.query("SELECT name, max_payout, JACIN_type, JAC_nums, before_RT, after_RT FROM bonus_data")
	var results = db.query_result
	
	for row in results:
		var bonus_name = row["name"]
		var max_payout = row["max_payout"]
		if max_payout:
			max_payout = int(max_payout)
		var JACIN_type = row["JACIN_type"]
		var JAC_nums = row["JAC_nums"]
		if JAC_nums:
			JAC_nums = JSON.parse_string(JAC_nums)
		var before_RT = row["before_RT"]
		var after_RT = row["after_RT"]
		if not bonus_data.has(bonus_name):
			var data = {
				"name" : bonus_name,
				"max_payout" : max_payout,
				"JACIN_type" : JACIN_type,
				"JAC_nums" : JAC_nums,
				"before_RT" : before_RT,
				"after_RT" : after_RT
			}
			bonus_data[bonus_name] = data


#reel_table(リールテーブル)作成
#[[L],[C],[R]]
func load_reel_table():
	db.query("SELECT reel_pos, reel_id, reel_design FROM reel_table")
	var results = db.query_result

	for i in range(3):
		reel_table[i].resize(pattern_sum)

	for row in results:
		# print(row)
		var reel_pos =  int(row["reel_pos"])
		var reel_id = int(row["reel_id"])
		var design = row["reel_design"]
		reel_table[reel_pos][reel_id] = design


#フラグ抽選
func select_flags(value):
	if bet_medals == 3:
		if weight_table.has(current_state):
			var current_weight_table = weight_table[current_state]
			for data in current_weight_table:
				var weight = int(data["weight"])
				value -= weight
				if value < 0:
					return(data["flag"])
			return("vac")
		else:
			print("error : current_state is %s" % [current_state])
			return
	else:
		return

	# if bet_medals == 3:
	# 	var current_weight_table = weight_table["Normal"]
	# 	for data in current_weight_table:
	# 		var weight: int = data["weight"]
	# 		value -= weight
	# 		if value < 0:
	# 			return(data["flag"])
	# 	return("vac")
	# else:
	# 	return


#乱数生成
func drawing():
	var loop_duration : int = 500000
	var current_time = Time.get_ticks_usec()
	var current_value: float = current_time % loop_duration
	var ratio: float = float(current_value) / float(loop_duration)
	var result_value: int = int(ratio * 65536)
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
	active_tweens[reel_pos].tween_callback(func(): is_spinning[reel_pos] = false)
	await active_tweens[reel_pos].finished

	reel.position.y = fmod(reel.position.y, reel_length)

	if active_tweens[reel_pos]:
		active_tweens[reel_pos].kill()
	
	if not is_spinning[0] and not is_spinning[1] and not is_spinning[2]:
		while Input.is_anything_pressed():
			await get_tree().process_frame
	
		check_prize()


func check_prize():

	if JAC_game:
		JAC_counter[1] -= 1

	if not JAC_game and RT_game != 0:
		RT_game -= 1
		if RT_game <= 0:
			end_RT()

	var reel_result : Array = get_reel_result()

	var matched_role = get_matched_role(reel_result)

	if matched_role:
		role_prize(matched_role)

	if JAC_game:
		print(JAC_counter)
		if JAC_counter[0] <= 0 or JAC_counter[1] <= 0:
			end_JAC()

	if current_bonus and max_bonus_payout > 0:
		if current_bonus_payout >= max_bonus_payout:
			end_bonus()
	
	result_flag = null


func role_prize(matched_role):
	var role = matched_role["name"]
	var payout = matched_role["payout"]
	var kind = matched_role["kind"]

	MY += payout

	if current_bonus and max_bonus_payout > 0:
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
	current_bonus = role

	if not max_payout:
		if current_state == "RT0":
			start_JAC(JACIN_type)
			return
		else:
			start_JAC(JACIN_type)
			return
	
	if JACIN_type:
		max_bonus_payout = max_payout
		current_bonus_payout = 0
		start_JAC(JACIN_type)
	else:
		max_bonus_payout = max_payout
		current_bonus_payout = 0
		current_state = role



func start_JAC(JAC):
	print("JAC_IN")
	JAC_game = true
	JAC_counter = JAC_data[JAC].duplicate()
	current_state = JAC


func end_JAC():
	JAC_game = false
	JAC_counter = [0,0]
	current_state = "RT0"
	print("JAC_END")

	if current_bonus and max_bonus_payout > 0:
		current_state = current_bonus
		var JACIN_type = bonus_data[current_bonus]["JACIN_type"]
		if JACIN_type:
			print("AUTO_JACIN")
			start_JAC(JACIN_type)
		else:
			pass

	elif current_bonus:
		end_bonus()
	

func end_bonus():
	JAC_game = false
	JAC_counter = [0, 0]
	current_state = "RT0"
	var after_RT = bonus_data[current_bonus]["after_RT"]
	if after_RT:
		start_RT(after_RT)
	print("%s IS END" % [current_bonus])
	current_bonus = null
	max_bonus_payout = 0
	current_bonus_payout = 0


func start_RT(RT):
	var RT_type = RT_data[RT]["type"]
	if RT_level > RT_type:
		return
	RT_game = 0
	RT_level = RT_type
	current_state = RT
	var game = RT_data[RT]["game"]
	if game:
		RT_game = game
		print(game)
	pass


func end_RT():
	RT_level = 0
	current_state = "RT0"