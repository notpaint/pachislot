extends Node2D

const pattern_scale : float = 128.0
const pattern_sum : int = 5
const pattern_per : float = 1.0 / pattern_sum

var db : SQLite
var db_path = "database_v2.db"

var flag_table : Dictionary = {}
var control_table : Dictionary = {}

var is_spinning = false
var spin_speed : float = 500.0

var active_tween : Tween
var current_pixel : float = 0.0
var current_scale : float = 0.0
var current_ID : int = 0

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
				var result_role = select_flags(rand_num)
				if not result_role == "vac": 
					print(flag_table[result_role]["target"])
				
				is_spinning = true
				print(flag_table)

		if event.keycode == KEY_ENTER:
			if is_spinning:
				stop_reels('middleBell')
				is_spinning = false



#フラグデータ読み込み
func load_data_from_db():

	var order = """
	SELECT
	f.flag_name, f.state, f.weight,
	r.name, r.kind , r.payout, r.pattern
	FROM
	mapping AS m
	JOIN
	roles AS r
	ON
	m.role_id = r.id
	JOIN
	flags AS f
	ON
	m.flag_id = f.id
	ORDER BY f.id
	"""

	db.query(order)
	var results = db.query_result
	for row in results:
		var f_name = row["flag_name"]
		if not flag_table.has(f_name):
			flag_table[f_name] = {
				"weight": row["weight"],
				"target": []
			}

		var target_info = {
			"role_name": row["name"],
			"kind": row["kind"],
			"payout": row["payout"],
			"pattern": row["pattern"]
		}

		flag_table[f_name]["target"].append(target_info)

		

	order = """
	SELECT
	r.name,
	s.reel_pos, s.reel_ID, s.slide
	FROM
	slides AS s
	JOIN
	roles AS r
	ON
	s.role_ID = r.id
	"""

	db.query(order)
	results = db.query_result
	for row in results:
		var r_name = row["name"]
		var r_pos = int(row["reel_pos"])
		var r_ID = int(row["reel_ID"])
		var r_slide = int(row["slide"])
		if not control_table.has(r_name):
			control_table[r_name] = [[], [], []]
			for i in range(3):
				control_table[r_name][i].resize(pattern_sum)
				control_table[r_name][i].fill(0)
		control_table[r_name][r_pos][r_ID] = r_slide


#フラグ抽選
func select_flags(value):
	for flag_name in flag_table:
		var weight: int = flag_table[flag_name]["weight"]
		value -= weight
		if value < 0:
			return(flag_name)
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
	
	current_pixel = L_reel.position.y
	current_scale = fmod((current_pixel / pattern_scale) , 1.0)

	if current_scale < 0.35:
		return
	
	var target_pixel : float = ceil(current_pixel / pattern_scale) * pattern_scale
	current_ID = int(floor(fmod((target_pixel /pattern_scale), pattern_sum)))
	var slide = control_table[flag][0][current_ID]
	target_pixel += (pattern_scale * slide)
	var target_speed : float = abs(target_pixel - current_pixel) / spin_speed

	active_tween = create_tween()
	active_tween.tween_property(L_reel, "position:y" , target_pixel, target_speed)
	active_tween.tween_callback(set.bind("is_spinning", false))
	await active_tween.finished

	L_reel.position.y = fmod(L_reel.position.y, 640.0)

	if active_tween:
		active_tween.kill()