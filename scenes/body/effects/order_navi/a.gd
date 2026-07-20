extends Node

@onready var effects = $"../.."
@onready var mainROM = $"../../../mainROM"

var bonus_variety:Array = []

var last_bonus_payout: int = 0
var get_bonus_payout: int = 0:
	set(value):
		if get_bonus_payout == value:
			return
		get_bonus_payout = value
		bonus_payout.emit(value)

var JAC_counter: Array = []

var bet_medals: int = 0

var active_bonus: String = "":
	set(value):
		if active_bonus == value:
			return
		active_bonus = value
		active_bonus_up.emit(value)

var parrot_weight = 205

signal bonus_payout(value)
signal active_bonus_up(value)
signal BB_data(get_pay, last_pay)
signal RB_data(jac)
signal parrot_animation(bool)

func _ready() -> void:
	bonus_variety = main.bonus_variety

func _on_prized(value):
	if value:
		if value["name"] in bonus_variety:
			await get_tree().process_frame
			switch_bonus(value)

	if active_bonus == "BB":
		if not value:
			return
		var payout = value["payout"]
		get_bonus_payout += int(payout)
		last_bonus_payout = max(0, last_bonus_payout - payout)

		BB_data.emit(get_bonus_payout, last_bonus_payout)

		if last_bonus_payout <= 0:
			end_bonus()
	
	elif active_bonus == "RB":
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
	effects.reset_game_count()

func _on_medal_bet(_value):
	bet_medals = min(3, bet_medals + 1)

func _on_flag(_value):

	effects.count_up_game()

	if active_bonus != "":
		get_bonus_payout = max(0, get_bonus_payout - bet_medals)
	bet_medals = 0
	if active_bonus == "BB":
		BB_data.emit(get_bonus_payout, last_bonus_payout)

func _on_bonus_est(value):
	if not effects.bonus_state:
		parrot_animation.emit(false)
		return

	if value != "RB":
		var parrot_rand = effects.get_effect_rand("parrot")
		if parrot_rand >= parrot_weight:
			await mainROM.spin_start
	parrot_animation.emit(true)


func switch_bonus(_value):

	if mainROM.max_bonus_payout > 0:
		last_bonus_payout = mainROM.max_bonus_payout
		get_bonus_payout = 0
		active_bonus = "BB"
	
	else:
		JAC_counter = mainROM.JAC_counter.duplicate(true)
		active_bonus = "RB"
	
