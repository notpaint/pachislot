extends Node

@onready var effects = $"../.."
@onready var audio = $"../../audio"
@onready var order_navi = $"../../order_navi"
@onready var mainROM = $"../../../mainROM"

var RT_game: int:
	get:
		return effects.RT_game

var bonus_variety: Array = []

var bet_medals: int = 0

var bonus: String = ""

var get_bonus_payout: int = 0
var last_bonus_payout:int = 0
var JAC_counter: Array = []

var current_RT: String = "RT0"

var now_RT: bool = false:
	set(value):
		if now_RT == value:
			return
		now_RT = value
		on_now_RT.emit(value)

var prized_role: String = ""
var active_bonus: String = "":
	set(value):
		if active_bonus == value:
			return
		active_bonus = value
		active_bonus_up.emit(value)

signal active_bonus_up(value)
signal on_now_RT(value)
signal BB_data(get_pay, last_pay)
signal RB_data(jac)

func _ready() -> void:
	bonus_variety = main.bonus_variety

func _on_medal_bet(_value):
	bet_medals = min(3, bet_medals + 1)
	if current_RT == "RT1":
		audio.back_music("RT1")

func _on_now_RT(value):

	current_RT = value
	
	match value:
		"RT0":
			if effects.current_bonus == "None":
				now_RT = false
		"RT1":
			now_RT = true
		"RT2":
			now_RT = true
			audio.back_music("RT2")


func _on_flag(value):

	if active_bonus.is_empty():
		effects.count_up_game()
	else:
		get_bonus_payout = max(0, get_bonus_payout - bet_medals)
		if active_bonus == "BB":
			BB_data.emit(get_bonus_payout, last_bonus_payout)
	
	bet_medals = 0

	order_navi.clear_navi()

	if now_RT and value == "TReplay1":
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
			bonus = value["name"]
			await get_tree().process_frame
			audio.play_bonus(bonus)
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
	if RT_game == 0:
		audio.back_music("RT_end", true)


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

			BB_data.emit(get_bonus_payout, last_bonus_payout)

			if last_bonus_payout <= 0:
				end_bonus()

		"RB":
			JAC_counter = mainROM.JAC_counter.duplicate(true)
			if value:
				var payout = value["payout"]
				get_bonus_payout += payout

			RB_data.emit(JAC_counter)

			if not JAC_counter.is_empty():
				if JAC_counter[0] <= 0 or JAC_counter[1] <= 0:
					end_bonus()

func end_bonus():
	active_bonus = ""
	last_bonus_payout = 0
	get_bonus_payout = 0
	JAC_counter = []
	audio.end_bonus(bonus)
	effects.reset_game_count()
		