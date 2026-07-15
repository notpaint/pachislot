extends Node2D


@onready var effects = $"../.."
@onready var audio = $"../../audio"
@onready var test = $"test"
@onready var order_navi = $"../../order_navi"
var mainROM: Node
var order_node: Node

var first_bet: bool = false

var result_flag: String
var current_bonus: String

var play_state: String: 
	set(value):
		if play_state == value:
			return
		play_state = value

var order_bell: Dictionary = {
	"213Bell": [2, 1, 3],
	"312Bell": [3, 1, 2],
	"231Bell": [2, 3, 1],
	"321Bell": [3, 2, 1]
}

func _ready():
	if effects and effects.order_node:
		order_node = effects.order_node
		connect_to_order_node(order_node)

func connect_to_order_node(node):
	if node.has_signal("maxbet"):
		node.maxbet.connect(_on_maxbet)
	if node.has_signal("flaged"):
		node.flaged.connect(_on_flaged)
	if node.has_signal("left_pre"):
		node.left_pre.connect(_on_left_pre)
	if node.has_signal("play_state_update"):
		node.play_state_update.connect(_on_play_state_update)
	if node.has_signal("bonus_wait"):
		node.bonus_wait.connect(_on_bonus_wait)
	if node.has_signal("bonus_start"):
		node.bonus_start.connect(_on_bonus_start)
	if node.has_signal("bonus_pre"):
		node.bonus_pre.connect(_on_bonus_pre)
	if node.has_signal("bonus_left"):
		node.bonus_left.connect(_on_bonus_left)
	if node.has_signal("bonus_ended"):
		node.bonus_ended.connect(_on_bonus_ended)
	if node.has_signal("AT_start"):
		node.AT_start.connect(_on_AT_start)
	if node.has_signal("AT_left"):
		node.AT_left.connect(_on_AT_left)
	if node.has_signal("AT_ended"):
		node.AT_ended.connect(_on_AT_ended)


func _on_flaged(value):

	result_flag = value

	if first_bet:
		first_bet = false
		force_music_start()

	
	match play_state:
		"normal":
			pass
		
		"bonus_waiting":
			bell_navi()

		"in_bonus":
			bell_navi()

		"AT":
			bell_navi()


func _on_left_pre(value):
	pass

func _on_play_state(value):
	
	match value:
		"bonus_waiting":
			pass

func _on_AT_left(game):
	test.get_node("bonus").text = str(game)


func _on_play_state_update(value):
	play_state = value

func _on_bonus_wait():
	first_bet = true

func _on_bonus_start(bonus, game):
	audio.back_music("silent")
	current_bonus = bonus
	first_bet = true

	await audio.wait_se_finished()

	if bonus != "RB":
		audio.back_music("select")

func _on_bonus_ended(bonus):
	audio.end_bonus(bonus)

func _on_AT_start():
	first_bet = true

func _on_AT_ended():
	audio.back_music("itadaki_end", true)


func _on_maxbet():
	if play_state == "":
		play_state = order_node.play_state

	match play_state:

		"bonus_waiting":
			if first_bet:
				first_bet = false
				audio.back_music("bonus_waiting")
		"in_bonus":
			if first_bet:
				first_bet = false
				play_bonus_music(current_bonus)
		"AT":
			if first_bet:
				first_bet = false
				audio.back_music("itadaki_start")



func play_bonus_music(bonus):
	audio.back_music("silent")
	await audio.wait_se_finished()

	if bonus == "RB":
		audio.play_bonus("RB")
	else:
		audio.play_bonus("redBB")

func _on_bonus_pre(value):
	pass

func _on_bonus_left(value):
	test.get_node("left").text = str(value)


func check_bet_sound() -> bool:
	
	match play_state:
		"bonus_waiting":
			return result_flag in ["fake_Replay", "r7_Replay"]
		"in_bonus":
			return first_bet

	return false


func force_music_start():
	match play_state:
		"bonus_waiting":
			audio.back_music("bonus_waiting")
		"in_bonus":
			audio.back_music("silent")
			if current_bonus == "RB":
				audio.play_bonus("RB")
			else:
				audio.play_bonus("redBB")

		"AT":
			audio.back_music("silent")
			audio.back_music("itadaki_start")


func bell_navi():
	if order_bell.has(result_flag):
		var order = Array(order_bell[result_flag])
		order_navi.set_navi(order, Color.YELLOW)