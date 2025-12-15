extends CanvasLayer

@onready var main_rom = $"../mainROM"

@onready var flag_name = $flag_name

func _process(delta):
	if main_rom:
		if not str(main_rom.result_flag) == null:
			flag_name.text = str(main_rom.result_flag)
