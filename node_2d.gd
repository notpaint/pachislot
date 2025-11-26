extends Node2D

const pattern_scale : float = 128.0
const pattern_sum : int = 5
const pattern_per : float = 1.0 / pattern_sum

var db : SQLite
var db_path = "database_v2.db"

var weight_table : Dictionary = {}
var flag_table : Dictionary = {}
var control_table : Dictionary = {}

var is_spinning = false
var spin_speed : float = 500.0

var active_tween : Tween
var current_pixel : float = 0.0
var current_scale : float = 0.0
var current_ID : int = 0

var result_flag = null

@onready var L_reel = $window/L_reel

func _ready():
	db = SQLite.new()
	db.path = db_path
	db.open_db()

	load_data_from_db()


#回転処理
func _process(delta: float):
	if is_spinning:
		L_reel.position.y += spin_speed * delta
		if L_reel.position.y >= 640:
			L_reel.position.y -= 640
	

#入力処理
func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_SPACE:
			if not is_spinning:
				var rand_num :int = drawing()
				result_flag = select_flags(rand_num)
				print(result_flag)
				if not result_flag == "vac": 
					pass
				
				is_spinning = true

		if event.keycode == KEY_ENTER:
			if is_spinning:
				stop_reels(result_flag)
				is_spinning = false



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


	#control_table(小役の制御表)作成
	order = """
	SELECT
	r.role,
	s.reel_pos, s.reel_ID, s.slide
	FROM
	slide_table AS s
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


#リール停止処理
func stop_reels(flag):
	if active_tween:
		active_tween.kill()
	
	if flag == "vac":
		return
	
	var role = flag_table[flag][0]["role"]
	current_pixel = L_reel.position.y
	current_scale = fmod((current_pixel / pattern_scale) , 1.0)

	# if current_scale < 0.35:
	# 	return
	
	var target_pixel : float = ceil(current_pixel / pattern_scale) * pattern_scale
	current_ID = int(floor(fmod((target_pixel /pattern_scale), pattern_sum)))
	var slide = control_table[role][0][current_ID]
	target_pixel += (pattern_scale * slide)
	var target_speed : float = abs(target_pixel - current_pixel) / spin_speed

	active_tween = create_tween()
	active_tween.tween_property(L_reel, "position:y" , target_pixel, target_speed)
	active_tween.tween_callback(set.bind("is_spinning", false))
	await active_tween.finished

	L_reel.position.y = fmod(L_reel.position.y, 640.0)

	if active_tween:
		active_tween.kill()
	print(current_ID)