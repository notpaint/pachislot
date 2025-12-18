extends CanvasLayer

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
		mainROM.prized.connect(_on_prized)

func _on_prized(reel_result):
	print(reel_result)



func _unhandled_input(event):
	if event.is_action_pressed("debug"):
		var font : Font = flag_name.get_theme_font("font_size")
		print(font)
