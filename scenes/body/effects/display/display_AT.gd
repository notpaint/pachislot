extends Node2D

@onready var effects = $"../.."
@onready var test = $"test"

var order_node: Node

func _ready():
	if effects and effects.order_node:
		order_node = effects.order_node
		connect_to_order_node(order_node)

func connect_to_order_node(node):
	if node.has_signal("left_pre"):
		node.left_pre.connect(_on_left_pre)
	if node.has_signal("bonus_pre"):
		node.bonus_pre.connect(_on_bonus_pre)
	if node.has_signal("bonus_left"):
		node.bonus_left.connect(_on_bonus_left)

func _on_left_pre(value):
	pass

func _on_bonus_pre(value):
	if value != "None":
		test.get_node("bonus").text = str(value)

func _on_bonus_left(value):
	test.get_node("left").text = str(value)
