extends Node2D

const pattern_scale : float = 128.0
const pattern_sum : int = 21
const reel_length : float = pattern_scale * pattern_sum
const pattern_per : float = 1.0 / pattern_sum

var db : SQLite
var db_path = "database_v2.db"

var weight_table : Dictionary = {}
var flag_table : Dictionary = {}
var all_roles : Dictionary = {}
var control_table : Dictionary = {}
var reel_table : Array = [[],[],[]]
var current_reel : Array = [[],[],[]]
var miss_patterns: Array = []
var current_control_table : Array = []
var valid_roles : Array = []

var is_spinning = [false, false, false]

var max_spin_speed : float = 1000
var acceralation : float = 1000
var current_spin_speed : Array = [0.0, 0.0, 0.0]

var active_tweens : Array[Tween] = [null, null, null]

var result_flag = null

var current_state = "Normal"

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
			current_spin_speed[i] = move_toward(current_spin_speed[i], max_spin_speed, acceralation * delta)
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
		if not is_spinning[0] and not is_spinning[1] and not is_spinning[2]:
			current_reel = [[],[],[]]
			valid_roles = []
			miss_patterns = []
			var rand_num :int = drawing()
			result_flag = select_flags(rand_num)
			print(result_flag)

			current_control_table = create_control_data(result_flag)
			for i in range (3):
				is_spinning[i] = true


	if event.is_action_pressed("stop_left"):
		try_stop_reel(0)
	if event.is_action_pressed("stop_center"):
		try_stop_reel(1)
	if event.is_action_pressed("stop_right"):
		try_stop_reel(2)

	if event.is_action_pressed("debug"):
		for role in all_roles:
			print(all_roles[role]["pattern"][1])
		
		


func try_stop_reel(reel_pos):
	var reel = reels[reel_pos]
	var current_pixel = reel.position.y
	var raw_ID = get_raw_ID(current_pixel)
	var base_ID = posmod(raw_ID, pattern_sum)
	var supposed_symbols : Array = get_supposed_symbols(base_ID, reel_pos)

	if is_spinning[0] and is_spinning[1] and is_spinning[2]:
		if result_flag == "vac":
			var slide = current_control_table[0]["slide"][reel_pos][base_ID]
			stop_reels(slide,current_pixel ,raw_ID ,reel_pos)
		else:
			var slide = table_logic(
				supposed_symbols, current_control_table, reel_pos, base_ID
				)
			var target_ID = posmod(raw_ID + slide, pattern_sum)
			current_reel[reel_pos] = reel_table[reel_pos][target_ID]
			stop_reels(slide,current_pixel ,raw_ID ,reel_pos)
	else:
		if result_flag == "vac":
			var slide = current_control_table[0]["slide"][reel_pos][base_ID]
			print(slide)
			stop_reels(slide,current_pixel ,raw_ID ,reel_pos)
		else:
			var slide = control_logic(
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

func table_logic(supposed_symbols, control_data, reel_pos, base_ID):
	for row in control_data:
		var slide = row["slide"][reel_pos][base_ID]
		var kind = row["kind"]
		var payout = row["payout"]
		var target_symbol = row["pattern"][reel_pos]
		for i in (supposed_symbols.size()):
			var supposed_data = supposed_symbols[i]
			if i == slide and supposed_data["symbol"] == target_symbol:
				supposed_data["kind"] = kind
				supposed_data["combo"] += 1
				if supposed_data["payout"] > payout:
					supposed_data["payout"] = payout
				var pattern = row["pattern"]
				var data = {
					"pattern" : pattern,
					"kind" : kind,
					"payout": payout
				}
				valid_roles.append(data)
		
	if not valid_roles.is_empty():
		supposed_symbols.sort_custom(sorting_symbols)
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
				var supposed_data = supposed_symbols[i]
				if supposed_data["symbol"] == valid_symbol:
					supposed_data["kind"] = kind
					supposed_data["combo"] += 1
					if supposed_data["payout"] > payout:
						supposed_data["payout"] = payout
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
	print(ghosts)
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
			var role_pattern = all_roles[role]["pattern"]
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
	return x["slide"] < y["slide"]


#フラグデータ読み込み
func load_data_from_db():

	load_weight_table()
	load_flag_table()
	load_control_table()
	load_all_roles()
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
	db.query("SELECT role, payout, kind, pattern FROM roles")
	var results = db.query_result

	for row in results:
		var role = row["role"]
		var payout = int(row["payout"])
		var kind = int(row["kind"])
		var pattern = JSON.parse_string(row["pattern"])
		all_roles[role] = []
		# var data = {"payout": payout, "kind": kind, "pattern":pattern}
		# all_roles[role].append(data)
		all_roles[role] = {
			"payout": payout,
			"kind": kind,
			"pattern": pattern
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
	value = 65535
	var current_weight_table = weight_table["Normal"]
	for data in current_weight_table:
		var weight: int = data["weight"]
		value -= weight
		if value < 0:
			return(data["flag"])
	return("vac")


#乱数生成
func drawing():
	var loop_duration : int = 500000
	var current_time = Time.get_ticks_usec()
	var current_value: float = current_time % loop_duration
	var ratio: float = float(current_value) / float(loop_duration)
	var result_value: int = int(ratio * 65536)
	return(result_value)


#当選役の制御テーブル作成
func create_control_data(flag):
	var control_data = []
	var i = 0

	if not flag == "vac":
		var roles = flag_table[flag]
		# print(roles)
		for row in roles: 
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
	else:
		var vac_data : Dictionary
		vac_data["slide"] = control_table["vac"]
		vac_data["payout"] = 0
		control_data.append(vac_data)

	print(control_data)
	return(control_data)


func get_raw_ID(pixel):
	var raw_current_scale = pixel / pattern_scale
	var raw_ID = int(ceil(raw_current_scale))
	return (raw_ID)


#リール停止処理
func stop_reels(slide, current_pixel, raw_ID, reel_pos):

	is_spinning[reel_pos] = false

	var reel = reels[reel_pos]
	var target_pixel = raw_ID * pattern_scale

	print(slide)

	target_pixel += (slide * pattern_scale)
	var target_speed : float = abs(target_pixel - current_pixel) / current_spin_speed[reel_pos]
	active_tweens[reel_pos] = create_tween()
	active_tweens[reel_pos].tween_property(reel, "position:y" , target_pixel, target_speed)
	active_tweens[reel_pos].tween_callback(func(): is_spinning[reel_pos] = false)
	await active_tweens[reel_pos].finished

	reel.position.y = fmod(reel.position.y, reel_length)

	if active_tweens[reel_pos]:
		active_tweens[reel_pos].kill()

func check_prize():
	var reel_result : Array = [[],[],[]]
	for i in range(3):
		var reel = reels[i]
		var current_pixel = reel.position.y
		var raw_ID = get_raw_ID(current_pixel)
		var base_ID = posmod(raw_ID, pattern_sum)
		reel_result[i] = reel_table[i][base_ID]
	print(reel_result)
