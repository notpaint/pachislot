extends Node2D

@onready var effects = $"../.."
@onready var test = $"test"
@onready var audio = $"../../audio"

var bonus_first_bet: bool = false

var result_flag: String
var current_bonus: String

var play_state: String: 
	set(value):
		if play_state == value:
			return
		play_state = value
		_on_play_state(value)

var order_node: Node
# var audio = Node

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
	if node.has_signal("bonus_start"):
		node.bonus_start.connect(_on_bonus_start)
	if node.has_signal("bonus_pre"):
		node.bonus_pre.connect(_on_bonus_pre)
	if node.has_signal("bonus_left"):
		node.bonus_left.connect(_on_bonus_left)
	if node.has_signal("bonus_ended"):
		node.bonus_ended.connect(_on_bonus_ended)


func _on_flaged(value):

	result_flag = value

	if bonus_first_bet:
		bonus_first_bet = false
		force_bonus_music()
	
	match play_state:
		pass


func _on_left_pre(value):
	pass

func _on_play_state(value):
	
	match value:
		"bonus_waiting":
			pass


func _on_play_state_update(value):
	play_state = value


func _on_bonus_start(bonus, game):
	current_bonus = bonus
	bonus_first_bet = true

	await audio.wait_se_finished()

	if bonus != "RB":
		audio.back_music("select")


func _on_maxbet():
	match play_state:
		"in_bonus":
			if bonus_first_bet:
				bonus_first_bet = false
				play_bonus_music(current_bonus)


func play_bonus_music(bonus):
	audio.back_music("silent")
	await audio.wait_se_finished()

	if bonus == "RB":
		audio.play_bonus("RB")
	else:
		audio.play_bonus("redBB")

func _on_bonus_pre(value):
	if value != "None":
		test.get_node("bonus").text = str(value)

func _on_bonus_left(value):
	test.get_node("left").text = str(value)

func _on_bonus_ended(bonus):
	effects.audio.end_bonus(bonus)


func check_bet_sound() -> bool:
	
	match play_state:
		"bonus_waiting":
			return result_flag in ["fake_Replay", "r7_Replay"]
		"in_bonus":
			return bonus_first_bet

	return false

func force_bonus_music():
	audio.back_music("silent")
	if current_bonus == "RB":
		audio.play_bonus("RB")
	else:
		audio.play_bonus("redBB")