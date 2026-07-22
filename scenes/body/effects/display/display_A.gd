extends Node2D

@onready var effects = $"../.."
@onready var mainROM = $"../../../mainROM"

@onready var BB_back = $"BB_back"
@onready var RB_back = $"RB_back"

@onready var parrot = $"parrot"
@onready var reverseparrot = $"reverseparrot"

@onready var bb_data_node = $"bb_data"
@onready var rb_data_node = $"rb_data"
@onready var total_data_node = $"total_data"

var parrot_weight = 205

var JAC_counter: Array = []

var last_bonus_payout: int = 0
var get_bonus_payout: int = 0:
	set(value):
		if get_bonus_payout == value:
			return
		get_bonus_payout = value
		bonus_get_update()

var bonus_payout_target: int = 0
var total_payout: int = 0
var order_node: Node
var active_data_node: Node = null

var bonus_variety:Array = []

var count_tween: Tween

func _ready():

	initialize_display()

	if effects and effects.order_node:
		order_node = effects.order_node
		connect_to_order_node(order_node)

	bonus_variety = main.bonus_variety


func connect_to_order_node(node):
	if node.has_signal("maxbet"):
		node.maxbet.connect(_on_maxbet)
	if node.has_signal("active_bonus_up"):
		node.active_bonus_up.connect(_on_active_bonus)
	if node.has_signal("BB_data"):
		node.BB_data.connect(_on_BB_data)
	if node.has_signal("RB_data"):
		node.RB_data.connect(_on_RB_data)
	if node.has_signal("parrot_animation"):
		node.parrot_animation.connect(_on_parrot_animation)

func initialize_display():
	BB_back.visible = true
	RB_back.visible = false

	bb_data_node.visible = false
	rb_data_node.visible = false
	total_data_node.visible = false

func _on_active_bonus(type):

	if type != "":
		await mainROM.medal_bet

	bb_data_node.visible = false
	rb_data_node.visible = false
	total_data_node.visible = false
	parrot.visible = false
	
	match type:
		"BB":
			bb_data_node.visible = true
			active_data_node = bb_data_node
			bb_data_node.get_node("GET_PAY").text = str(order_node.get_bonus_payout)
			bb_data_node.get_node("LAST_PAY").text = str(order_node.last_bonus_payout)
		"RB":
			rb_data_node.visible = true
			BB_back.visible = false
			RB_back.visible = true
			active_data_node = rb_data_node
			var counter = order_node.JAC_counter
			rb_data_node.get_node("LAST_PRIZE").text = "%2d" % counter[0]
			rb_data_node.get_node("LAST_PLAY").text = "%2d" % counter[1]
		"":
			total_data_node.visible = true
			active_data_node = total_data_node
			total_data_node.get_node("TOTAL").text = str(order_node.get_bonus_payout)

			await mainROM.medal_bet

			BB_back.visible = true
			RB_back.visible = false
			total_data_node.visible = false
			parrot.visible = true
			active_data_node = null
			total_payout = 0

func _on_maxbet():
	pass




func _on_BB_data(get_pay, last_pay):
	if active_data_node == bb_data_node:
		bonus_payout_target = get_pay
		bonus_count_up()
		bb_data_node.get_node("LAST_PAY").text = str(last_pay)

func _on_RB_data(counter):
	if active_data_node == rb_data_node:
		rb_data_node.get_node("LAST_PRIZE").text = "%2d" % counter[0]
		rb_data_node.get_node("LAST_PLAY").text = "%2d" % counter[1]

func bonus_count_up():
	if count_tween:
		count_tween.kill()
	var steps := bonus_payout_target - get_bonus_payout
	if steps <= 0:
		get_bonus_payout = bonus_payout_target
		return
	count_tween = create_tween()
	count_tween.set_loops(steps)
	count_tween.tween_callback(func(): get_bonus_payout += 1)
	count_tween.tween_interval(0.5 / steps)

func bonus_get_update():
	if not bb_data_node.visible == true:
		return
	
	bb_data_node.get_node("GET_PAY").text = "%d" % get_bonus_payout

func _on_parrot_animation(value):
	if value:
		parrot.play("parrot")
		reverseparrot.play("reverseparrot")
	else:
		await mainROM.medal_bet
		stop_parrot(parrot)
		stop_parrot(reverseparrot)

func stop_parrot(sprite):
	if sprite.is_playing():
		while sprite.frame != 0:
			await sprite.frame_changed
			if effects.bonus_state:
				return
		sprite.stop()
		sprite.frame = 0
