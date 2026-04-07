extends Node

var db : SQLite
var db_path = "database_v2.db"

const pattern_sum : int = 21

var weight_table : Dictionary = {}
var flag_table : Dictionary = {}
var all_roles : Dictionary = {}
var control_table : Dictionary = {}
var vac_pattern : Dictionary = {}
var pattern_priority: Dictionary = {}
var JAC_data : Dictionary = {}
var RT_data : Dictionary = {}
var bonus_data : Dictionary = {}
var reel_table : Array = [[],[],[]]

var HUD_data : Dictionary = {"vac": "ハズレ"}

func _ready():
	db = SQLite.new()
	db.path = db_path
	db.open_db()
	load_data_from_db()

func load_data_from_db():
	load_weight_table()
	load_flag_table()
	load_control_table()
	load_pattern_priority_table()
	load_all_roles()
	load_JAC_data()
	load_RT_data()
	load_bonus_data()
	load_reel_table()
	load_HUD_data()
	load_vac_pattern()

#weight_table(フラグの確率表)作成
#{"weight_state":[{"flag", "weight"}]}
func load_weight_table():
	var order = """
	SELECT 
	f.flag,
	ft.bonus_state, ft.RT_state, ft.bet_state, ft.weight
	FROM
	flags AS f
	JOIN
	flag_table AS ft ON ft.flag_id = f.id
	"""

	db.query(order)
	var results = db.query_result

	for row in results:
		var flag = row["flag"]
		var bonus_state = row["bonus_state"]
		var RT_state = row["RT_state"]
		var bet_state = int(row["bet_state"])
		var weight = int(row["weight"])
		if not weight_table.has(bonus_state):
			weight_table[bonus_state] = {}
		if not weight_table[bonus_state].has(RT_state):
			weight_table[bonus_state][RT_state] = {}
		if not weight_table[bonus_state][RT_state].has(bet_state):
			weight_table[bonus_state][RT_state][bet_state] = []
		var data = {"flag": flag, "weight": weight}
		weight_table[bonus_state][RT_state][bet_state].append(data)


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
		var miss_pattern_array = row["miss_pattern"]
		if miss_pattern_array:
			miss_pattern_array = JSON.parse_string(miss_pattern_array)
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
		var miss_pattern = row["miss_pattern"]
		if miss_pattern:
			miss_pattern = JSON.parse_string(miss_pattern)
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
	db.query("SELECT reel_pos, reel_ID, slide FROM vac_control_table")
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

func load_vac_pattern():
	db.query("SELECT pattern FROM vac_pattern")
	var results = db.query_result

	var row = results[0]
	var pattern = JSON.parse_string(row["pattern"])
	vac_pattern = {"pattern" : pattern}

func load_pattern_priority_table():
	
	var order = """
	SELECT
	r.role,
	pp.role_id, pp.bonus_state, pp.reel_pos, pp.reel_ID, pp.priority, pp.route
	FROM
	role_pattern_priority AS pp
	JOIN
	roles AS r ON pp.role_id = r.id
	"""
	
	db.query(order)
	var results = db.query_result
	
	for row in results:
		var role = row["role"]
		var bonus_state = row["bonus_state"]
		var reel_pos = int(row["reel_pos"])
		var reel_ID = int(row["reel_ID"])
		var priority = int(row["priority"])
		var route = row["route"]
		if not pattern_priority.has(role):
			pattern_priority[role] = {}
		if not pattern_priority[role].has(bonus_state):
			pattern_priority[role][bonus_state] = {}
		if not pattern_priority[role][bonus_state].has(reel_pos):
			pattern_priority[role][bonus_state][reel_pos] = {}
		if not pattern_priority[role][bonus_state][reel_pos].has(route):
			pattern_priority[role][bonus_state][reel_pos][route] = {}
		pattern_priority[role][bonus_state][reel_pos][route][reel_ID] = priority


func load_JAC_data():
	db.query("SELECT name, prize_count, play_count, play_bet FROM JAC_data")
	var results = db.query_result

	for row in results:
		var JAC_name = row["name"]
		var prize_count = int(row["prize_count"])
		var play_count = int(row["play_count"])
		var play_bet = int(row["play_bet"])
		var data = {
			"counter" : [prize_count, play_count],
			"bet": play_bet
		}
		JAC_data[JAC_name] = data

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

func load_HUD_data():
	var order = """
	SELECT
	f.flag,
	fH.flag_name
	FROM
	flag_HUD AS fH
	JOIN
	flags AS f ON f.id = fH.flag_ID
	"""

	db.query(order)
	var results = db.query_result

	for row in results:
		var flag = row["flag"]
		var display_name = row["flag_name"]
		HUD_data[flag] = display_name