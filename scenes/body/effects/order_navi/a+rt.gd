extends Node

@onready var effects = $"../.."
@onready var audio = $"../../audio"
@onready var order_navi = $"../../order_navi"
@onready var mainROM = $"../../../mainROM"

var RT_game: int:
	get:
		return effects.RT_game

var bonus_variety: Array = []

var get_bonus_payout: int = 0
var last_bonus_payout:int = 0
var JAC_counter: Array = []

var current_RT: String = "RT0"
var now_RT = false

var prized_role: String = ""
var active_bonus: String = ""

func _ready() -> void:
	bonus_variety = main.bonus_variety

func _on_medal_bet(_value):
	if current_RT == "RT1":
		audio.back_music("RT1")

func _on_now_RT(value):
	current_RT = value
	if value == "RT1" or value == "RT2":
		now_RT = true
	elif value == "RT0" and effects.current_bonus == "None":
		if now_RT:
			audio.back_music("RT_end", true)
		now_RT = false

	if value == "RT2":
		audio.back_music("RT2")


func _on_flag(value):

	if active_bonus == "":
		effects.count_up_game()

	order_navi.clear_navi()

	if value == "TReplay1":
		if RT_game <= 8:
			order_navi.set_navi([null, null, 1])
		else:
			order_navi.set_navi([1, null, null])

func _on_stop_button(reel_pos):
	order_navi.push_navi(reel_pos)

func _on_reel_stopped(reel_pos, _stopped_reel, _current_reel_grid):
	pass


func _on_prized(value):
	if value:
		prized_role = value["name"]
		if prized_role in bonus_variety:
			await get_tree().process_frame
			switch_bonus()

	if active_bonus != "":
		handle_bonus(value)

	if now_RT:
		handle_RT(value)

func handle_RT(value):

	if effects.bonus_state and value == null:
		audio.back_music("silent")
	if prized_role == "SReplay":
		audio.back_music("silent")

func switch_bonus():

	if mainROM.max_bonus_payout > 0:
		last_bonus_payout = mainROM.max_bonus_payout
		get_bonus_payout = 0
		active_bonus = "BB"
	
	else:
		JAC_counter = mainROM.JAC_counter.duplicate(true)
		active_bonus = "RB"

func handle_bonus(value):
	
	match active_bonus:

		"BB":
			if not value:
				return
			var payout = value["payout"]
			get_bonus_payout += int(payout)
			last_bonus_payout = max(0, last_bonus_payout - payout)

			if last_bonus_payout <= 0:
				end_bonus()

		"RB":
			JAC_counter = mainROM.JAC_counter.duplicate(true)
			if value:
				var payout = value["payout"]
				get_bonus_payout += payout

			if not JAC_counter.is_empty():
				if JAC_counter[0] <= 0 or JAC_counter[1] <= 0:
					end_bonus()

func end_bonus():
	active_bonus = ""
	last_bonus_payout = 0
	get_bonus_payout = 0
	JAC_counter = []
	effects.reset_game_count()
		