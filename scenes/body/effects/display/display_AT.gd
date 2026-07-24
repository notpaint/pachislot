extends Node2D


@onready var effects = $"../.."
@onready var audio = $"../../audio"
@onready var order_navi = $"../../order_navi"

@onready var layer_root = $"layers"
@onready var char_select = $"layers/char_select"
@onready var shatter = $"shatter"
@onready var background = $"background"
@onready var portrit = $"portrit"

@onready var mainROM = $"../../../mainROM"
var order_node: Node

var first_bet: bool = true
var navi_game: bool = true

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


var current_bonus_condi: String
var bonus_game: int = 0
var bonus_get: int = 0:
	set(value):
		if bonus_get == value:
			return
		bonus_get = value
		# bonus_get_update()

var stage_game: int = -1

# var bonus_get_target: int = 0

var AT_game: int = 200
var total_get_target: int = 0
var total_get: int = 0:
	set(value):
		if total_get == value:
			return
		total_get = value
		# total_get_update()

var order_bell: Dictionary = {
	"213Bell": [2, 1, 3],
	"312Bell": [3, 1, 2],
	"231Bell": [2, 3, 1],
	"321Bell": [3, 2, 1]
}

var bonus_tween:Tween
var total_tween:Tween

func _ready():
	if effects and effects.order_node:
		order_node = effects.order_node
		connect_to_order_node(order_node)
	if char_select:
		char_select.character.connect(_on_character)
	if shatter:
		pass


func connect_to_order_node(node):
	#common
	_connect_signal(node, "maxbet", _on_maxbet)
	_connect_signal(node, "flaged", _on_flaged)
	_connect_signal(node, "left_pre", _on_left_pre)
	_connect_signal(node, "play_state_update", _on_play_state_update)
	_connect_signal(node, "mode_update", _on_mode_update)
	_connect_signal(node, "bonus_wait", _on_bonus_wait)
	#bonus
	_connect_signal(node, "bonus_condi_update", _on_bonus_condi)
	_connect_signal(node, "bonus_start", _on_bonus_start)
	_connect_signal(node, "bonu_pre", _on_bonus_pre)
	_connect_signal(node, "bonus_left", _on_bonus_left)
	_connect_signal(node, "bonus_payout", _on_bonus_payout)
	_connect_signal(node, "bonus_ended", _on_bonus_ended)
	#AT
	_connect_signal(node, "AT_start", _on_AT_start)
	_connect_signal(node, "AT_left", _on_AT_left)
	_connect_signal(node, "AT_ended", _on_AT_ended)
	_connect_signal(node, "total_pay", _on_total_pay)

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

	# order_navi.clear_navi()
	navi_game = false

	if first_bet:
		first_bet = false
		force_switch_layer()

	
	match play_state:
		"normal":
			pass
		
		"bonus_waiting":
			navi_game = true
			bell_navi()

		"in_bonus":
			navi_game = true
			bell_navi()
			if showing_layer and showing_layer.name == "in_bonus":
				showing_layer._on_flaged(value)

		"AT":
			navi_game = true
			if stage_game > 0:
				stage_game -= 1
			bell_navi()


func _on_left_pre(value):
	pass

func _on_mode_update(value) -> void:
	current_mode = value

func _on_play_state(value):
	
	match value:
		"bonus_waiting":
			pass

func _on_AT_left(value):
	AT_game = value

	if not showing_layer or showing_layer.name != "AT":
		return

	var playing = showing_layer.get_node_or_null("playing")
	if not playing or not playing.visible:
		return
	
	playing.get_node("LEFT_GAME").text = "%dG" % AT_game


func _on_play_state_update(value):
	play_state = value

func _on_bonus_wait():
	first_bet = true

func _on_bonus_condi(condi):
	current_bonus_condi = condi
	stage_game = 3


func _on_bonus_start(bonus, game):
	audio.back_music("silent")
	current_bonus = bonus
	first_bet = true

	await audio.wait_se_finished()

	if bonus != "RB":
		audio.back_music("select")
		switch_layers("char_select")

func _on_bonus_ended(bonus):
	if showing_layer and showing_layer.name == "in_bonus":
		if showing_layer.bonus_updating == true:
			mainROM.bet_block += 1
			await showing_layer.bonus_updated
			mainROM.bet_block -= 1
	showing_layer.end_bonus(total_get)
	audio.end_bonus(bonus)

func _on_AT_start():
	first_bet = true

func _on_AT_ended():
	audio.back_music("itadaki_end", true)


func _on_maxbet():
	order_navi.clear_navi()

	if play_state == "":
		play_state = order_node.play_state

	match play_state:

		"normal":
			if first_bet:
				switch_layers("normal")

		"bonus_waiting":
			if first_bet:
				first_bet = false
				audio.back_music("bonus_waiting")
				switch_layers("bonus_waiting")
		"in_bonus":
			if first_bet:
				first_bet = false
				play_bonus_music(current_bonus)
		"AT":
			if first_bet:
				first_bet = false
				audio.back_music("itadaki_start")
				switch_layers("AT")
			
			if stage_game == 0:
				stage_game = -1
				switch_background("day")



func play_bonus_music(bonus):
	audio.back_music("silent")
	await audio.wait_se_finished()
	switch_layers("in_bonus")

	if bonus == "RB":
		audio.play_bonus("RB")
	else:
		audio.play_bonus("redBB", selected_char)

func _on_bonus_pre(value):
	pass

func _on_bonus_left(value):
	bonus_game = value

func _on_bonus_payout(value):
	bonus_get = value
	if showing_layer and showing_layer.name == "in_bonus":
		showing_layer.update_bonus_get(bonus_get)

func _on_total_pay(value):
	total_get_target = value
	total_count_up()


func total_count_up():
	if total_tween:
		total_tween.kill()
	if total_get_target <= total_get:
		total_get = total_get_target
		return
	total_tween = create_tween()
	total_tween.tween_property(self, "total_get", total_get_target, 0.3)


# func bonus_get_update():
# 	if not showing_layer or showing_layer.name != "in_bonus":
# 		return

# 	var playing = showing_layer.get_node_or_null("playing")
# 	if not playing or not playing.visible:
# 		return
	
# 	playing.get_node("GET_PAY").text = "%d" % bonus_get

# func total_get_update():
# 	if not showing_layer:
# 		return

# 	var playing = showing_layer.get_node_or_null("playing")
# 	if not playing or not playing.visible:
# 		return
	
# 	playing.get_node("TOTAL_PAY").text = "%d" % total_get

func _on_character(char_name: String):
	selected_char = char_name

func force_switch_layer():
	match play_state:

		"bonus_waiting":
			switch_layers("bonus_waiting")
			audio.back_music("bonus_waiting")
			
		"in_bonus":
			audio.back_music("silent")
			switch_layers("in_bonus")
			if current_bonus == "RB":
				audio.play_bonus("RB")
			else:
				audio.play_bonus("redBB", selected_char)

		"AT":
			switch_layers("AT")
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

		"normal":
			switch_background("morning")

		"bonus_waiting":
			shatter.in_bonus_shatter()
			await shatter.shatter_closed
			switch_background("black")
			for image in portrit.get_children():
				image.visible = false

			await get_tree().create_timer(1.5).timeout

			showing_layer.first_part()

		"char_select":
			pass

		"in_bonus":
			switch_background("morning")
			showing_layer.start_bonus(bonus_game)

		"AT":
			showing_layer.get_node("playing").visible = true
			showing_layer.get_node("result").visible = false

			showing_layer.get_node("playing/LEFT_GAME").text = "%dG" % AT_game
			showing_layer.get_node("playing/TOTAL_PAY").text = str(total_get_target)


func switch_background(back: String) -> void:
	for child in background.get_children():
		child.visible = (child.name == back)

func in_bonus_layer():
	pass

func check_bet_sound() -> bool:
	
	match play_state:
		"bonus_waiting":
			return result_flag in ["fake_Replay", "r7_Replay"]
		"in_bonus":
			return first_bet

	return false

func check_button_sound() -> bool:

	if play_state == "in_bonus" or play_state == "bonus_waiting":
		return false

	return result_flag in order_bell and not order_navi.navi_miss and navi_game


func check_heaven_music(track) -> bool:

	if AT_game < 99 or current_mode != "Heaven":
		return false

	match track:
		'todoroki':
			return selected_char == "todoroki"
		'hanamiti':
			return selected_char == "kaoru"
		'distance':
			return selected_char == "misao"

	return false
