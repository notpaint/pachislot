extends PanelContainer


@onready var mode_data = $"spacer/contents/mode_data"
@onready var mode_data_template = $"spacer/contents/mode_data/template"

var order_node: Node

var current_mode: String:
	set(value):
		current_mode = value
		update_mode(value)

var release_game: int:
	set(value):
		release_game = value
		update_game(value)

func _ready() -> void:
	order_node = sub.order_node
	connect_to_order_node()
	initialize_data()

func connect_to_order_node():
	if order_node:
		_connect_signal(order_node, "mode_update", _on_mode_update)
		_connect_signal(order_node, "release_game_update", _on_release_game)
		_connect_signal(order_node, "bonus_ended", _on_bonus_ended)

func initialize_data():
	mode_data_template.visible = false

func _connect_signal(sender: Node, signal_name: StringName, method: Callable) -> void:
	if sender.has_signal(signal_name):
		sender.connect(signal_name, method)

func _on_mode_update(value):
	current_mode = value

func _on_release_game(value):
	release_game = value


func update_mode(value):
	var display_value = value
	if display_value == "Heaven":
		display_value = "天国"
	var current_label = mode_data.get_node("current/data/mode/status")
	var next_label = mode_data.get_node("next/data/mode/status")

	if current_label.text == "ー":
		current_label.text = display_value
		return
	else:
		next_label.text = display_value

func update_game(value):

	if value < 0:
		return

	var current_label = mode_data.get_node("current/data/game/status")
	var next_label = mode_data.get_node("next/data/game/status")

	if current_label.text == "ー":
		current_label.text = str(value)
		return
	else:
		next_label.text = str(value)

func _on_bonus_ended(value):
	var current_data = mode_data.get_node_or_null("current")
	var next_data = mode_data.get_node_or_null("next")

	var new_node = mode_data_template.duplicate(true)

	if current_data:
		current_data.name = "old"
		current_data.queue_free()

	if next_data:
		next_data.name = "current"
		var arrow = next_data.get_node_or_null("arrow")
		arrow.visible = false

	if new_node:
		new_node.name = "next"
		new_node.visible = true
		mode_data.add_child(new_node)

	

	


	
