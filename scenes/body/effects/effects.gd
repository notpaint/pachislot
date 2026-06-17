extends Node

@onready var mainROM = $"../mainROM"
@onready var audio = $"audio"
@onready var frame_light = $"frame_light"
@onready var reel_light = $"reel_light"
@onready var symbol_light = $"symbol_light"
@onready var order_assist = $"order_assist"

var now_RT = false
var current_bonus = "None"

var effects_seed : int

#16個の8bit乱数
#AT []
var effects_rands: PackedByteArray

var jac_counter: int = 0
var order_scene_path:String

signal medal_bet()
signal main_flag(value)
signal jac_count()
signal bonus_end()
signal prized()

func _ready():
	order_scene_path = sub.order_scene_path

	for child in order_assist.get_children():
		child.queue_free()
	if order_scene_path:
		var order_scene = load(order_scene_path)
		var scene = order_scene.instantiate()
		order_assist.add_child(scene)
	else:
		print("押し順無し")

	if mainROM:
		connect_to_mainROM()

func connect_to_mainROM():
	if mainROM.has_signal("bonus_est"):
		mainROM.bonus_est.connect(_on_bonus_est)
	if mainROM.has_signal("bonus_prized"):
		mainROM.bonus_prized.connect(_on_bonus_prized)
	if mainROM.has_signal("medal_bet"):
		mainROM.medal_bet.connect(_on_medal_bet)
	if mainROM.has_signal("flag"):
		mainROM.flag.connect(_on_flag)
	if mainROM.has_signal("spin_start"):
		mainROM.spin_start.connect(_on_spin_start)
	if mainROM.has_signal("reel_stopped"):
		mainROM.reel_stopped.connect(_on_reel_stopped)
	if mainROM.has_signal("now_RT"):
		mainROM.now_RT.connect(_on_now_RT)
	if mainROM.has_signal("JAC_IN"):
		mainROM.JAC_IN.connect(_on_JAC_IN)
	if mainROM.has_signal("prized"):
		mainROM.prized.connect(_on_prized)

func _on_spin_start():
	audio.play_spin_start()

func _on_JAC_IN():
	jac_counter += 1
	if jac_counter == 3:
		jac_count.emit()

func _on_flag(value):
	effects_seed = mainROM.effects_seed
	effects_rands = drawing_hash_array(effects_seed)
	main_flag.emit(value)
	print(effects_rands)

func _on_bonus_est(value):
	pass

func _on_bonus_prized(value):
	current_bonus = value
	if value != "None":
		audio.play_bonus(value)
	if value == "None":
		bonus_end.emit()
		print("bonus_end: effects")
		jac_counter = 0

func _on_medal_bet(value):
	audio.play_bet(value)
	reel_light.stop_flash()
	symbol_light.stop_flash()
	medal_bet.emit()
	# medal_bet.emit(value)

func _on_prized(value):
	var current_reel_grid = mainROM.current_reel_grid
	reel_light.replay_flash()
	# symbol_light.middle_flash(current_reel_grid)


func _on_reel_stopped(_current_reel, _current_reel_grid):
	audio.play_reel_stop()

func _on_now_RT(value):
	if value == "RT3":
		now_RT = true
	elif value == "RT0":
		now_RT = false

func bit_array(v):
	return (
		[v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF]
	)

func drawing_hash_array(seed_number):
	
	var h = hash(seed_number)
	var i = hash(seed_number + 1)

	var a = hash(h & 0xFFFF)
	var b = hash((h >> 16) & 0xFFFF)

	var c = hash(i & 0xFFFF)
	var d = hash((i >> 16) & 0xFFFF)


	return PackedByteArray(bit_array(a) + bit_array(b) + bit_array(c) + bit_array(d))
