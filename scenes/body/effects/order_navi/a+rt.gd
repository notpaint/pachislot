extends Node

@onready var effects = $"../.."
@onready var order_navi = $"../../order_navi"
@onready var mainROM = $"../../../mainROM"

var RT_game: int:
	get:
		return effects.RT_game

var current_RT: String = "RT0"
var now_RT = false


func _on_now_RT(value):
	current_RT = value
	if value == "RT1" or value == "RT2":
		now_RT = true
	elif value == "RT0" and effects.current_bonus == "None":
		now_RT = false


func _on_flag(value):
	# if value == "TReplay1" and current_RT == "RT1":
	if value == "TReplay1":
		if RT_game <= 8:
			frame_light_on(2, Color.WHITE)
			order_navi.set_navi([null, null, 1])
		else:
			frame_light_on(0, Color.WHITE)
			order_navi.set_navi([1, null, null])

func _on_stop_button(reel_pos):
	order_navi.push_navi(reel_pos)


func frame_light_on(reel_pos, color):
	var pos = effects.frame_lights[reel_pos]
	pos.visible = true
	pos.default_color = color

func frame_light_off(reel_pos):
	var pos = effects.frame_lights[reel_pos]
	pos.visible = false

func _on_reel_stopped(reel_pos, _stopped_reel, _current_reel_grid):
	frame_light_off(reel_pos)

func _on_prized(value):
	pass
