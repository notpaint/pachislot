extends Node2D


@onready var effects = $"../.."
@onready var audio = $"../../audio"
@onready var test = $"test"
@onready var order_navi = $"../../order_navi"
@onready var layer_root = $"layers"

var mainROM: Node
var order_node: Node

var first_bet: bool = false

var result_flag: String
var current_bonus: String
var selected_char: String = "todoroki"

var current_mode: String = "Heaven"

var play_state: String: 
	set(value):
		if play_state == value:
			return
		play_state = value

var showing_layer: Node

var bonus_game: int = 0
var bonus_get: int = 0:
	set(value):
		if bonus_get == value:
			return
		bonus_get = value
		bonus_get_update()

var bonus_get_target: int = 0

var AT_game: int = 200

var order_bell: Dictionary = {
	"213Bell": [2, 1, 3],
	"312Bell": [3, 1, 2],
	"231Bell": [2, 3, 1],
	"321Bell": [3, 2, 1]
}

var count_tween:Tween

func _ready():
	if effects and effects.order_node:
		order_node = effects.order_node
		connect_to_order_node(order_node)

func connect_to_order_node(node):
	#common
	_connect_signal(node, "maxbet", _on_maxbet)
	_connect_signal(node, "flaged", _on_flaged)
	_connect_signal(node, "left_pre", _on_left_pre)
	_connect_signal(node, "play_state_update", _on_play_state_update)
	_connect_signal(node, "bonus_wait", _on_bonus_wait)
	#bonus
	_connect_signal(node, "bonus_start", _on_bonus_start)
	_connect_signal(node, "bonu_pre", _on_bonus_pre)
	_connect_signal(node, "bonus_left", _on_bonus_left)
	_connect_signal(node, "bonus_payout", _on_bonus_payout)
	_connect_signal(node, "bonus_ended", _on_bonus_ended)
	#AT
	_connect_signal(node, "AT_start", _on_AT_start)
	_connect_signal(node, "AT_left", _on_AT_left)
	_connect_signal(node, "AT_ended", _on_AT_ended)

func _connect_signal(node: Node, signal_name: StringName, callable: Callable) -> void:
	if node.has_signal(signal_name):
		node.connect(signal_name, callable)

func _unhandled_input(event):
	if not event.is_pressed() or event.is_echo():
		return

	if event.is_action_pressed("menu_left"):
		pass

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
		audio.play_bonus("redBB", selected_char)
		switch_layers("in_bonus")

func _on_bonus_pre(value):
	pass

func _on_bonus_left(value):
	bonus_game = value

	if not showing_layer or showing_layer.name != "in_bonus":
		return

	var playing = showing_layer.get_node_or_null("playing")
	if not playing or not playing.visible:
		return
	
	playing.get_node("LAST_GAME").text = "%dG" % bonus_game


func _on_bonus_payout(value):
	bonus_get_target = value
	bonus_count_up()

func bonus_count_up():
	if count_tween:
		count_tween.kill()
	var steps := bonus_get_target - bonus_get
	if steps <= 0:
		bonus_get = bonus_get_target
		return
	count_tween = create_tween()
	count_tween.set_loops(steps)
	count_tween.tween_callback(func(): bonus_get += 1)
	count_tween.tween_interval(0.3 / steps)

func bonus_get_update():
	if not showing_layer or showing_layer.name != "in_bonus":
		return

	var playing = showing_layer.get_node_or_null("playing")
	if not playing or not playing.visible:
		return
	
	playing.get_node("GET_PAY").text = "%d" % bonus_get


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
			switch_layers("in_bonus")
			if current_bonus == "RB":
				audio.play_bonus("RB")
			else:
				audio.play_bonus("redBB", selected_char)

		"AT":
			audio.back_music("silent")
			audio.back_music("itadaki_start")


func bell_navi():
	if order_bell.has(result_flag):
		var order = Array(order_bell[result_flag])
		order_navi.set_navi(order, Color.YELLOW)

func switch_layers(layer: String) -> void:
	for child in layer_root.get_children():
		child.visible = (child.name == layer)
	showing_layer = layer_root.get_node_or_null(layer)

	match layer:

		"bonus_waiting":
			pass

		"in_bonus":
			showing_layer.get_node("playing").visible = true
			showing_layer.get_node("result").visible = false

			showing_layer.get_node("playing/LAST_GAME").text = "%dG" % bonus_game
			showing_layer.get_node("playing/GET_PAY").text = str(0)


func in_bonus_layer():
	pass


func check_heaven_music(track):

	if AT_game < 99 or current_mode != "Heaven":
		return false

	match track:
		'todoroki':
			return selected_char == "todoroki"
		'distance':
			return selected_char == "misao"
