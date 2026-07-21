extends PanelContainer

@onready var flag_name = $"flag_name"

var HUD_data: Dictionary

func _ready() -> void:
	HUD_data = main.HUD_data
	flag_name.text = ""


func _on_flaged(result_flag):
	if HUD_data.has(result_flag):
		var display_name = HUD_data[result_flag]
		flag_name.text = display_name
	else:
		flag_name.text = result_flag
