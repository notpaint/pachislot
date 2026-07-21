extends Control

var symbol_image_folder = "assets/images/symbol_image/"
var bonus_symbols = ["r7", "bar", "b7"]

var HUD_data : Dictionary

@onready var reel_result_image = [
	$reel_result_UI/L_symbol,
	$reel_result_UI/C_symbol,
	$reel_result_UI/R_symbol
]

@onready var mainROM = $"../../mainROM"
@onready var flag_name = $flag_name
@onready var result_roles = $result_roles
@onready var roles = $"result_roles/roles"
@onready var est_bonus = $"detail/est/status"
@onready var now_bonus = $"detail/now/status"
@onready var RT_name = $"detail/rt/status/name"
@onready var RT_count = $"detail/rt/status/count"

func _ready():
	HUD_data = main.HUD_data
	if mainROM:
		mainROM.flag.connect(_on_flaged)
		mainROM.roles.connect(_on_roles)
		mainROM.prized_array.connect(_on_prized_array)
		mainROM.spin_start.connect(_on_spin_start)
		mainROM.bonus_est.connect(_on_bonus_est)
		mainROM.bonus_prized.connect(_on_bonus_prized)
		mainROM.now_RT.connect(_on_now_RT)
		mainROM.last_RT.connect(_on_last_RT)

func _on_prized_array(reel_result):
	for i in range(3):
		var symbol_name = reel_result[i]
		if symbol_name in bonus_symbols:
			reel_result_image[i].custom_minimum_size = Vector2(137, 97)
			# reel_result_image[i].custom_minimum_size = Vector2(200, 97)
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

func _on_roles(value):
	for child in roles.get_children():
		child.queue_free()
	for i in value.size():
		var role_name = value[i]["role"]
		var display_name = role_name
		if HUD_data.has(role_name):
			display_name = HUD_data[role_name]
		var label := Label.new()
		label.text = display_name
		roles.add_child(label)

func _on_spin_start():
	for i in range(3):
		reel_result_image[i].texture = null

func _on_bonus_est(bonus):
	if HUD_data.has(bonus):
		var display_name = HUD_data[bonus]
		est_bonus.text = display_name
	else:
		est_bonus.text = bonus if bonus else "ー"

func _on_bonus_prized(bonus):
	if HUD_data.has(bonus):
		var display_name = HUD_data[bonus]
		now_bonus.text = display_name
	else:
		if bonus == "None":
			now_bonus.text = "ー"
		else:
			now_bonus.text = bonus if bonus else "ー"

func _on_now_RT(RT):
	if RT == "None" or RT == "":
		RT_name.text = "RT0"
	else:
		RT_name.text = RT

func _on_last_RT(game):
	if game == 0:
		RT_count.text = str(0)
	elif game < 0:
		RT_count.text = "ー"
	else:
		RT_count.text = str(game)
	
