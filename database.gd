extends Node

var db : SQLite
var db_path = "database_v2.db"

var weight_table : Dictionary = {}
var flag_table : Dictionary = {}

func _ready():
	db = SQLite.new()
	db.path = db_path
	db.open_db()
	# load_weight_table()

# func load_weight_table():
# 	var order = """
#     SELECT
#     f.flag,
#     ws.weight_state,
#     ft.weight
#     FROM
#     flags AS f
#     JOIN
#     flag_table AS ft ON ft.flag_id = f.id
#     JOIN
#     weight_status AS ws ON ft.weight_status_id = ws.id
#     """
	
# 	db.query(order)
# 	var results = db.query_result

# 	for row in results:
# 		var flag = row["flag"]
# 		var weight_state = row["weight_state"]
# 		var weight = int(row["weight"])
# 		if not weight_table.has(weight_state):
# 			weight_table[weight_state] = []
# 		var data = {"flag": flag, "weight": weight}
# 		weight_table[weight_state].append(data)
