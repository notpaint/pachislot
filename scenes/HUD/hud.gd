extends CanvasLayer

var symbol_image_folder = "assets/images/symbol_image/"
var bonus_symbols = ["r7", "bar", "b7"]

@onready var reel_result_image = [
	$reel_result_UI/L_symbol,
	$reel_result_UI/C_symbol,
	$reel_result_UI/R_symbol
]

@onready var mainROM = $"../mainROM"
@onready var flag_name = $flag_name

# func _process(delta):
# 	if main_rom:
		# if not str(main_rom.result_flag) == null:
		# 	flag_name.text = str(main_rom.result_flag)
		# if not str(main_rom.current_reel) == null:
		# 	flag_name.text = str(main_rom.current_reel)

func _ready():
	if mainROM:
		mainROM.flag.connect(_on_flaged)
		mainROM.prized.connect(_on_prized)
		mainROM.spin_start.connect(_on_spin_start)
	if reel_result_image:
		print(reel_result_image)


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
	print(result_flag)

func _on_spin_start():
	for i in range(3):
		reel_result_image[i].texture = null

func _unhandled_input(event):
	if event.is_action_pressed("debug"):
		var font : Font = flag_name.get_theme_font("font_size")
		print(font)
