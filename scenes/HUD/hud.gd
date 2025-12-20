extends CanvasLayer

var db : SQLite
var db_path = "database_v2.db"

var symbol_image_folder = "assets/images/symbol_image/"
var bonus_symbols = ["r7", "bar", "b7"]

var HUD_data : Dictionary = {"vac": "ハズレ"}

@onready var reel_result_image = [
	$reel_result_UI/L_symbol,
	$reel_result_UI/C_symbol,
	$reel_result_UI/R_symbol
]

@onready var mainROM = $"../mainROM"
@onready var flag_name = $flag_name
@onready var result_role = $"result_role"

func _ready():
	db = SQLite.new()
	db.path = db_path
	db.open_db()
	load_HUD_data()

	if mainROM:
		mainROM.flag.connect(_on_flaged)
		mainROM.prized.connect(_on_prized)
		mainROM.spin_start.connect(_on_spin_start)
		mainROM.bonus_est.connect(_on_bonus_est)

func _on_prized(reel_result):
	for i in range(3):
		var symbol_name = reel_result[i]
		if symbol_name in bonus_symbols:
			reel_result_image[i].custom_minimum_size = Vector2(200, 97)
		else:
			reel_result_image[i].custom_minimum_size = Vector2(137, 97)
		var symbol_image_path = symbol_image_folder + symbol_name + ".png"
		var texture = load(symbol_image_path)
		reel_result_image[i].texture = texture


func _on_flaged(result_flag):
	if HUD_data.has(result_flag):
		var display_name = HUD_data[result_flag]
		flag_name.text = display_name
	else:
		flag_name.text = result_flag

func _on_spin_start():
	for i in range(3):
		reel_result_image[i].texture = null

func _unhandled_input(event):
	if event.is_action_pressed("debug"):
		var font : Font = flag_name.get_theme_font("font_size")
		print(font)

func _on_bonus_est(bonus):
	result_role.text = bonus if bonus else ""



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
