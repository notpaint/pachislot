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

@onready var detail_header = $"detail_header"
@onready var flag_header = $"flag_header"
@onready var role_header = $"role_header"
@onready var order_header = $"order_header"


func _ready():
	HUD_data = main.HUD_data
	if mainROM:
		if detail_header:
			_connect_signal(mainROM, "now_RT", detail_header._on_now_RT)
			_connect_signal(mainROM, "bonus_est", detail_header._on_bonus_est)
			_connect_signal(mainROM, "bonus_prized", detail_header._on_bonus_prized)
			_connect_signal(mainROM, "last_RT", detail_header._on_last_RT)
		if flag_header:
			_connect_signal(mainROM, "flag", flag_header._on_flaged)
		if role_header:
			_connect_signal(mainROM, "roles", role_header._on_roles)
		if order_header:
			pass


func _connect_signal(sender: Node, signal_name: StringName, method: Callable) -> void:
	if sender.has_signal(signal_name):
		sender.connect(signal_name, method)


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

func _on_spin_start():
	for i in range(3):
		reel_result_image[i].texture = null
