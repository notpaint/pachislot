extends Node

var db : SQLite

var db_path = ""
var db_path_dict = {
	"A": "res://db/A/sub.db",
	"AT": "res://db/AT/sub.db",
	"A+RT": "res://db/A+RT/sub.db"
}

var current_version: String
var order_scene_path: String

var SE_dict: Dictionary = {}
var bonus_music: Dictionary = {}
var rare_flags: Array = []
var effect_slot: Dictionary = {}

var flag_trigger: Dictionary = {}
var mode_data: Dictionary = {}
var premonition_data: Dictionary = {}

func _ready():
	if db_path == "":
		db_path = db_path_dict["A"]


func load_sub_db(version):
	if not db_path_dict.has(version):
		print("!!! Failed to load sub.db for version ", version, ". Defaulting to A !!!")
		version = "A"
	
	current_version = version

	if db:
		db.close_db()
	clear_data()

	var res_path = db_path_dict[version]
	var user_path = ""

	if OS.has_feature("editor"):
		user_path = res_path
	else:
		var exe_dir = OS.get_executable_path().get_base_dir()
		var db_folder = exe_dir + "/db"
		if not DirAccess.dir_exists_absolute(db_folder):
			DirAccess.make_dir_absolute(db_folder)
		var version_folder = db_folder + "/" + version
		if not DirAccess.dir_exists_absolute(version_folder):
			DirAccess.make_dir_absolute(version_folder)
		user_path = version_folder + "/sub.db"

		DirAccess.copy_absolute(res_path, user_path)

	db_path = user_path
	db = SQLite.new()
	db.path = db_path
	db.open_db()

	load_order_scene()
	load_rare_flags()
	load_effects_slot()
	load_data_from_db()

func load_order_scene():
	db.query("SELECT data FROM env WHERE name = 'order_scene_path'")
	var results = db.query_result

	if results:
		var scene_path = results[0]["data"]
		if scene_path:
			order_scene_path = scene_path

func load_rare_flags():
	db.query("SELECT data FROM env WHERE name = 'rare_flag'")
	var results = db.query_result

	if results:
		var item = results[0]["data"]
		if item:
			rare_flags = JSON.parse_string(item)

func load_effects_slot():
	db.query("SELECT data FROM env WHERE name = 'effect_rand'")
	var results = db.query_result

	if results:
		var item = results[0]["data"]
		if item:
			effect_slot = JSON.parse_string(item)
	print(effect_slot)


func clear_data():
	pass

func load_data_from_db():
	generate_bonus_music()
	generate_mode_data()
	generate_SE_dict()
	generate_premonition_data()
	generate_flag_trigger()

	print(flag_trigger)

func generate_SE_dict():
	db.query("SELECT name, rule, sound FROM SE")
	var results = db.query_result

	for row in results:
		var item = row["name"]
		var rule_json = row["rule"]
		rule_json = JSON.parse_string(rule_json)
		var sound_json = row["sound"]
		sound_json = JSON.parse_string(sound_json)

		for rule in rule_json:
			var cond = rule["cond"]
			if cond != "default":
				var expr = Expression.new()
				expr.parse(cond)
				rule["parsed"] = expr

		if not SE_dict.has(item):
			SE_dict[item] = {
				"rule": rule_json,
				"sound": sound_json
			}

func generate_bonus_music():
	db.query("SELECT bonus, jingle, rule, track_name, start, end FROM bonus_music")
	var results = db.query_result

	for row in results:
		var bonus = row["bonus"]
		var jingle = row["jingle"]
		var rule_array = row["rule"]
		rule_array = JSON.parse_string(rule_array)
		rule_array.sort_custom(func(a, b): return a["priority"] > b["priority"])
		for rule in rule_array:
			var cond = rule["cond"]
			if cond != "default":
				var expr = Expression.new()
				expr.parse(cond)
				rule["parsed"] = expr

		var track_name = row["track_name"]
		if not bonus_music.has(bonus):
			bonus_music[bonus] = {
				"jingle": jingle,
				"rule": rule_array,
				"tracks": {}
			}

		bonus_music[bonus]["tracks"][track_name] = {
			"start": row["start"],
			"end": row["end"]
		}

func generate_flag_trigger():
	db.query("SELECT flag, type, state, weight from flag_trigger")
	var results = db.query_result

	for row in results:
		var flag = row["flag"]
		if not flag_trigger.has(flag):
			flag_trigger[flag] = {}
		var type = row["type"]
		if not flag_trigger[flag].has(type):
			flag_trigger[flag][type] = {}
		var state = row["state"]
		var weight = row["weight"]
		flag_trigger[flag][type][state] = weight

func generate_mode_data():
	db.query("SELECT id, mode from mode_list")
	var results = db.query_result

	for row in results:
		var id = row["id"]
		var mode = row["mode"]
		mode_data[mode] = {
			"id": id,
			"release": {},
			"map": {},
			"ratio": {}
		}

	var release_order = """
	SELECT
	ml.mode,
	mr.game, mr.weight, mr.premonition
	FROM
	mode_release AS mr
	JOIN
	mode_list AS ml ON mr.mode_id = ml.id
	"""

	db.query(release_order)
	var release_results = db.query_result

	for row in release_results:
		mode_data[row.mode]["release"][row.game] = {
			"weight": row.weight,
			"premonition": row.premonition
		}
	
	var map_order = """
	SELECT
	cur.mode AS current_mode,
	nxt.mode AS next_mode,
	mm.weight
	FROM
	mode_map AS mm
	JOIN
	mode_list AS cur ON mm.mode_id = cur.id
	JOIN
	mode_list AS nxt ON mm.next_mode_id = nxt.id
	"""

	db.query(map_order)
	var map_results = db.query_result

	for row in map_results:
		mode_data[row.current_mode]["map"][row.next_mode] = row.weight

	var ratio_order = """
	SELECT
	ml.mode,
	mr.bonus, mr.weight
	FROM
	mode_ratio AS mr
	JOIN
	mode_list AS ml ON mr.mode_id = ml.id
	"""

	db.query(ratio_order)
	var ratio_results = db.query_result

	for row in ratio_results:
		mode_data[row.mode]["ratio"][row.bonus] = row.weight

func generate_premonition_data():
	db.query("SELECT type, trigger, flag, is_win, game, weight FROM premonition_map")
	var results = db.query_result

	for row in results:
		var type = row["type"]
		var trigger = row["trigger"]
		var flag = row["flag"]
		var is_win = bool(row["is_win"])
		var game = row["game"]
		var weight = row["weight"]
		if not premonition_data.has(type):
			premonition_data[type] = {}
		if not premonition_data[type].has(trigger):
			premonition_data[type][trigger] = {}
		if not premonition_data[type][trigger].has(flag):
			premonition_data[type][trigger][flag] = {}
		if not premonition_data[type][trigger][flag].has(is_win):
			premonition_data[type][trigger][flag][is_win] = {}
		premonition_data[type][trigger][flag][is_win][game] = weight
