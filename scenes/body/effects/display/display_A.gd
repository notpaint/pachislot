extends Node2D

@onready var effects = $"../.."
@onready var mainROM = $"../../../mainROM"

@onready var parrot = $"parrot"
@onready var reverseparrot = $"reverseparrot"

@onready var bb_data_node = $"bb_data"
@onready var rb_data_node = $"rb_data"
@onready var total_data_node = $"total_data"

var parrot_weight = 205

var JAC_counter: Array = []
var last_bonus_payout: int = 0
var get_bonus_payout: int = 0

var active_data_node: Node = null

var bonus_variety:Array = []

func _ready():
	bb_data_node.visible = false
	rb_data_node.visible = false

	bonus_variety = main.bonus_variety


func _on_bonus_est(value):
	if not effects.bonus_state:

		await mainROM.medal_bet

		stop_parrot(parrot)
		stop_parrot(reverseparrot)
		return
	
	if value != "RB":
		var parrot_rand = effects.get_effect_rand("parrot")
		if parrot_rand >= parrot_weight:
			await mainROM.spin_start
	parrot.play("parrot")
	reverseparrot.play("reverseparrot")

func _on_prized(value):

	if value:
		if value["name"] in bonus_variety:
			await mainROM.medal_bet
			switch_bonus(value)

	if bb_data_node.visible:
		if not value:
			return
		var payout = value["payout"]
		get_bonus_payout += payout
		bb_data_node.get_node("GET_PAY").text = str(get_bonus_payout)

		last_bonus_payout -= payout
		last_bonus_payout = max(last_bonus_payout, 0)
		bb_data_node.get_node("LAST_PAY").text = str(last_bonus_payout)

		if last_bonus_payout <= 0:
			bb_data_node.visible = false
			total_data_node.visible = true
			active_data_node = total_data_node
			total_data_node.get_node("TOTAL").text = str(get_bonus_payout)


	if rb_data_node.visible:
		JAC_counter = mainROM.JAC_counter.duplicate(true)
		var last_play = JAC_counter[1]
		var last_play_str = "%2d" % last_play
		var last_prize = JAC_counter[0]
		var last_prize_str = "%2d" % last_prize
		if value:
			var payout = value["payout"]
			get_bonus_payout += payout
		rb_data_node.get_node("LAST_PRIZE").text = last_prize_str
		rb_data_node.get_node("LAST_PLAY").text = last_play_str

		if last_prize <= 0 or last_play <= 0:
			rb_data_node.visible = false
			total_data_node.visible = true
			active_data_node = total_data_node
			total_data_node.get_node("TOTAL").text = str(get_bonus_payout)


func switch_bonus(_value):

	parrot.visible = false
	
	if mainROM.max_bonus_payout > 0:
		bb_data_node.visible = true
		active_data_node = bb_data_node
		last_bonus_payout = mainROM.max_bonus_payout
		get_bonus_payout = 0
		bb_data_node.get_node("LAST_PAY").text = str(last_bonus_payout)
		bb_data_node.get_node("GET_PAY").text = str(get_bonus_payout)
	else:
		rb_data_node.visible = true
		active_data_node = rb_data_node
		JAC_counter = mainROM.JAC_counter.duplicate(true)
		var last_prize = JAC_counter[0]
		last_prize = "%2d" % last_prize
		var last_play = JAC_counter[1]
		last_play = "%2d" % last_play
		rb_data_node.get_node("LAST_PRIZE").text = last_prize
		rb_data_node.get_node("LAST_PLAY").text = last_play


func _on_medal_bet(value):
	if value == 0:
		return

	if effects.current_bonus == "None" and active_data_node and active_data_node.visible:
		active_data_node.visible = false
		parrot.visible = true
		active_data_node = null
	
	if bb_data_node.visible:
		get_bonus_payout -= 1
		get_bonus_payout = max(get_bonus_payout, 0)
		bb_data_node.get_node("GET_PAY").text = str(get_bonus_payout)
	

func _on_spin_start():
	pass


func stop_parrot(sprite):
	if sprite.is_playing():
		while sprite.frame != 0:
			await sprite.frame_changed
			if effects.bonus_state:
				return
		sprite.stop()
		sprite.frame = 0
