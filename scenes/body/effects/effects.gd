extends Node

@onready var mainROM = $"../mainROM"
@onready var weight = $"weight"
@onready var audio = $"audio"
@onready var frame_light = $"frame_light"
@onready var reel_light = $"reel_light"
@onready var symbol_light = $"symbol_light"
@onready var order_assist = $"order_assist"

var rare_flag = sub.rare_flags

var now_RT = false
var bonus_state = null
var current_bonus = "None"

var result_flag: String
var prized_role: String

var current_reel: Array = ["", "" ,""]

var effects_seeds : PackedInt32Array

#256個の8bit乱数
var effects_rands: PackedByteArray

var effect_slot: Dictionary = {}

var jac_counter: int = 0
var order_scene_path:String

signal medal_bet()
signal main_flag(value)
signal jac_count()
signal bonus_end()
signal prized()

func _ready():
	order_scene_path = sub.order_scene_path
	effects_rands.resize(256)
	effect_slot = sub.effect_slot

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
	if mainROM.has_signal("prized_role"):
		mainROM.prized_role.connect(_on_prized_role)
	if mainROM.has_signal("prized_array"):
		mainROM.prized_array.connect(_on_prized_array)

func _on_spin_start():
	var track = weight.random_SE("reel_start")
	audio.play_spin_start(track)

func _on_JAC_IN():
	jac_counter += 1
	if jac_counter == 3:
		jac_count.emit()

func _on_flag(value):
	result_flag = value
	effects_seeds = mainROM.effects_seeds
	drawing_hash_array(effects_seeds)
	main_flag.emit(value)

func _on_bonus_est(value):
	bonus_state = value

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

func _on_prized_role(value):
	if value:
		prized_role = value["name"]
		audio.play_prized(value["name"])

func _on_prized_array(value):
	var current_reel_grid = mainROM.current_reel_grid
	# reel_light.replay_flash()
	# symbol_light.middle_flash(current_reel_grid)


func _on_reel_stopped(stopped_reel, _current_reel_grid):
	current_reel = stopped_reel
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

func drawing_hash_array(seed_numbers):
	var seed_number = seed_numbers[0]
	var salt_number = seed_numbers[1]

	var current = (seed_number << 16) + salt_number

	for i in range(64):
		current = hash(current)
		var offset = i * 4

		effects_rands[offset] = current & 0xFF
		effects_rands[offset + 1] = (current >>8) & 0xFF
		effects_rands[offset + 2] = (current >>16) & 0xFF
		effects_rands[offset + 3] = (current >>24) & 0xFF
	
