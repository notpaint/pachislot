extends Node2D


var db : SQLite
var db_path = "res://test_slot.sql"
var sql_file_path ="res://test.sql"

var mother : Dictionary = {}

var is_spinning = false
var spin_speed : float = 500.0

@onready var L_reel = $window/L_reel

func _ready():
	db = SQLite.new()
	db.path = db_path
	db.open_db()

	import_sql_from_file()


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
				is_spinning = false



#フラグデータ読み込み
func import_sql_from_file():
	var file = FileAccess.open(sql_file_path, FileAccess.READ)
	var sql_text = file.get_as_text()

	var _success = db.query(sql_text)

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
