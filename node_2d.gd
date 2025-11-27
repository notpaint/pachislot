extends Node2D

const pattern_scale : float = 128.0
const pattern_sum : int = 5
const pattern_per : float = 1.0 / pattern_sum

var db : SQLite
var db_path = "database_v2.db"

var weight_table : Dictionary = {}
var flag_table : Dictionary = {}
var control_table : Dictionary = {}
var current_control_table : Array

var is_spinning = [false, false, false]
var spin_speed : float = 400.0

var active_tweens = [[],[],[]]

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
				for i in range (3):
					is_spinning[i] = true
	
	if event.is_action_pressed("stop_left"):
		try_stop_reel(0)
	if event.is_action_pressed("stop_center"):
		try_stop_reel(1)
	if event.is_action_pressed("stop_right"):
		try_stop_reel(2)
		


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
	var results
	var order

	#weight_table(フラグの確率表)作成
	order = """
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
	results = db.query_result

	for item in results:
		var flag = item["flag"]
		var weight_state = item["weight_state"]
		var weight = int(item["weight"])
		if not weight_table.has(weight_state):
			weight_table[weight_state] = []
		var data = {"flag": flag,"weight" : weight}
		weight_table[weight_state].append(data)


	#flag_table(フラグの重複役一覧)作成
	order = """
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
	results = db.query_result

	for item in results:
		var flag = item["flag"]
		var role = item["role"]
		var kind = item["kind"]
		var payout = int(item["payout"])
		if not flag_table.has(flag):
			flag_table[flag] = []
		var data = {"role": role, "payout":payout, "kind": kind}
		flag_table[flag].append(data)

	#control_table(制御表)作成

	db.query("SELECT reel_pos, reel_ID, slide FROM vac_control")
	results = db.query_result

	for item in results:
		var reel_pos = int(item["reel_pos"])
		var reel_ID = int(item["reel_ID"])
		var slide = int(item["slide"])
		if not control_table.has("vac"):
			control_table["vac"] = [[],[],[]]
			for i in range(3):
				control_table["vac"][i].resize(pattern_sum)
		control_table["vac"][reel_pos][reel_ID] = slide

	order = """
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

	for item in results:
		var role = item["role"]
		var reel_pos = int(item["reel_pos"])
		var reel_ID = int(item["reel_ID"])
		var slide = int(item["slide"])
		if not control_table.has(role):
			control_table[role] = [[],[],[]]
			for i in range (3):
				control_table[role][i].resize(pattern_sum)
		control_table[role][reel_pos][reel_ID] = slide

	print(weight_table)
	print(flag_table)
	print(control_table)
		


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
	print(flag)

	if not flag == "vac":
		var roles = flag_table[flag]
		for row in roles: 
			i += 1
			var role = row["role"]
			var payout = row["payout"]
			var slide = control_table[role]
			var role_data : Dictionary
			role_data["slide"] = slide
			role_data["payout"] = payout
			role_data["priority"] = i
			control_data.append(role_data)
	else:
		var vac_data : Dictionary
		vac_data["slide"] = control_table["vac"]
		vac_data["payout"] = 0
		control_data.append(vac_data)

	
	return(control_data)

#リール停止処理
func stop_reels(control_data, reel_pos):
	is_spinning[reel_pos] = false
	var reel = reels[reel_pos]
	var current_pixel = reel.position.y
	var raw_current_scale = current_pixel / pattern_scale
	var base_ID = int(ceil(raw_current_scale))
	var slide = 0

	var search_ID = posmod(base_ID,5)

	var target_pixel = base_ID * pattern_scale
	
	for row in control_data:
		slide = row["slide"][reel_pos][search_ID]
		break

	target_pixel += (slide * pattern_scale)
	var target_speed : float = abs(target_pixel - current_pixel) / spin_speed
	active_tweens[reel_pos] = create_tween()
	active_tweens[reel_pos].tween_property(reel, "position:y" , target_pixel, target_speed)
	active_tweens[reel_pos].tween_callback(func(): is_spinning[reel_pos] = false)
	await active_tweens[reel_pos].finished

	reel.position.y = fmod(reel.position.y, 640.0)

	if active_tweens[reel_pos]:
		active_tweens[reel_pos].kill()


	# var role = flag_table[flag][0]["role"]
	# current_pixel = L_reel.position.y
	# current_scale = fmod((current_pixel / pattern_scale) , 1.0)

	# if current_scale < 0.35:
	# 	return
	
	# var target_pixel : float = ceil(current_pixel / pattern_scale) * pattern_scale
	# current_ID = int(floor(fmod((target_pixel /pattern_scale), pattern_sum)))
	# var slide = control_table[role][0][current_ID]
	# target_pixel += (pattern_scale * slide)
	# var target_speed : float = abs(target_pixel - current_pixel) / spin_speed

	# active_tween = create_tween()
	# active_tween.tween_property(L_reel, "position:y" , target_pixel, target_speed)
	# active_tween.tween_callback(set.bind("is_spinning", false))
	# await active_tween.finished

	# L_reel.position.y = fmod(L_reel.position.y, 640.0)

	# if active_tween:
	# 	active_tween.kill()
	# print(current_ID)
