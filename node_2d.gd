extends Node2D

const pattern_scale : float = 128.0
const pattern_sum : int = 5
const pattern_per : float = 1.0 / pattern_sum

var db : SQLite
var db_path = "database_v2.db"

var weight_table : Dictionary = {}
var flag_table : Dictionary = {}
var control_table : Dictionary = {}
var reel_table : Array = [[],[],[]]
var current_control_table : Array
var current_patterns = []

var is_spinning = [false, false, false]
var spin_speed : float = 800.0

var active_tweens : Array[Tween] = [null, null, null]

var result_flag = null

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
		if is_spinning[i]:
			reels[i].position.y += spin_speed * delta
			if reels[i].position.y >= 640:
				reels[i].position.y -= 640
	

#入力処理
func _unhandled_input(event):
	if not event.is_pressed() or event.is_echo():
		return

	if event.is_action_pressed("lever"):
		if not is_spinning[0] and not is_spinning[1] and not is_spinning[2]:
				var rand_num :int = drawing()
				result_flag = select_flags(rand_num)
				current_control_table = create_control_data(result_flag)
				print(current_control_table)
				for i in range (3):
					is_spinning[i] = true
	
	if event.is_action_pressed("stop_left"):
		try_stop_reel(0)
	if event.is_action_pressed("stop_center"):
		try_stop_reel(1)
	if event.is_action_pressed("stop_right"):
		try_stop_reel(2)

	if event.is_action_pressed("debug"):
		print(flag_table)
		


func try_stop_reel(reel_pos):
	if is_spinning[reel_pos]:
		stop_reels(current_control_table, reel_pos)
		# is_spinning[reel_pos] = false


	# 	if event.keycode == KEY_ENTER:
	# 		if is_spinning[0]:
	# 			stop_reels(create_control_data(result_flag), 0)
	# 			is_spinning[0] = false



#フラグデータ読み込み
func load_data_from_db():

	load_weight_table()
	load_flag_table()
	load_control_table()
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
	r.role, r.kind, r.payout, r.pattern
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
		if not flag_table.has(flag):
			flag_table[flag] = []
		var data = {"role" : role, "kind": kind, "payout": payout, "pattern": pattern_array}
		flag_table[flag].append(data)

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
		print(roles)
		for row in roles: 
			i += 1
			var role = row["role"]
			var payout = row["payout"]
			var pattern = row["pattern"]
			var slide = control_table[role]
			var role_data : Dictionary
			role_data["slide"] = slide
			role_data["payout"] = payout
			role_data["pattern"] = pattern
			role_data["priority"] = i
			control_data.append(role_data)
	else:
		var vac_data : Dictionary
		vac_data["slide"] = control_table["vac"]
		vac_data["payout"] = 0
		control_data.append(vac_data)

	
	return(control_data)


func get_raw_ID(pixel):
	var raw_current_scale = pixel / pattern_scale
	var raw_ID = int(ceil(raw_current_scale))
	return (raw_ID)


func culc_target(control_data, reel_pos, raw_ID):
	# var reel = reels[reel_pos]
	var slide = 0
	var base_ID = posmod(raw_ID,pattern_sum)
	for row in control_data:
		slide = row["slide"][reel_pos][base_ID]
		break
	var target_ID_raw = -(raw_ID + slide)
	var target_ID = posmod(target_ID_raw, pattern_sum)
	var target_design = reel_table[reel_pos][target_ID]
	for row in control_data:
		if row.has("pattern"):
			var role_design = row["pattern"][reel_pos]
			if target_design != role_design:
				print(target_design)
				print(role_design)
				return(slide)
			else:
				return(slide)
		else:
			print("当選役無し")
			return(slide)


#リール停止処理
func stop_reels(control_data, reel_pos):

	is_spinning[reel_pos] = false

	var reel = reels[reel_pos]
	var current_pixel = reel.position.y

	var raw_ID = get_raw_ID(current_pixel)
	var slide = culc_target(control_data, reel_pos, raw_ID)

	var target_pixel = raw_ID * pattern_scale

	target_pixel += (slide * pattern_scale)
	var target_speed : float = abs(target_pixel - current_pixel) / spin_speed
	active_tweens[reel_pos] = create_tween()
	active_tweens[reel_pos].tween_property(reel, "position:y" , target_pixel, target_speed)
	active_tweens[reel_pos].tween_callback(func(): is_spinning[reel_pos] = false)
	await active_tweens[reel_pos].finished

	reel.position.y = fmod(reel.position.y, 640.0)

	if active_tweens[reel_pos]:
		active_tweens[reel_pos].kill()

func check_prize():
	pass
