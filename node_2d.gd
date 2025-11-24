extends Node2D

const pattern_scale : float = 128.0
const pattern_sum : int = 5
const pattern_per : float = 1.0 / pattern_sum

var db : SQLite
var db_path = "res://test_slot.db"

var mother : Dictionary = {}

var is_spinning = false
var spin_speed : float = 500.0

var active_tween : Tween
var current_pixel : float = 0.0
var current_scale : float = 0.0


@onready var L_reel = $window/L_reel

func _ready():
	db = SQLite.new()
	db.path = db_path
	db.open_db()

	load_db_from_file()


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
				print(rand_num)
				print(result_role)
				if not result_role == "vac": 
					print(mother[result_role]["target"])
				
				is_spinning = true

		if event.keycode == KEY_ENTER:
			if is_spinning:
				stop_reels()
				is_spinning = false



#フラグデータ読み込み
func load_db_from_file():

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
		if not mother.has(f_name):
			mother[f_name] = {
				"weight": row["weight"],
				"target": []
			}

		var target_info = {
			"role_name": row["name"],
			"kind": row["kind"],
			"payout": row["payout"],
			"pattern": row["pattern"]
		}

		mother[f_name]["target"].append(target_info)


#フラグ抽選
func select_flags(value):
	for flag_name in mother:
		var weight: int = mother[flag_name]["weight"]
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
func stop_reels():
	if active_tween:
		active_tween.kill()
	current_pixel = L_reel.position.y
	current_scale = fmod((current_pixel / pattern_scale) , 1)
	if current_scale < 0.35:
		return
	var target_pixel : float = ceil(current_pixel / pattern_scale) * pattern_scale
	var target_speed : float = abs(target_pixel - current_pixel) / spin_speed
	active_tween = create_tween()
	active_tween.tween_callback(set.bind("is_spinning", false))
	active_tween.tween_property(L_reel, "position:y" , target_pixel, target_speed)
	await active_tween.finished
	if active_tween:
		active_tween.kill