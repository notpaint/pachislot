extends Node

@onready var mainROM = $"../mainROM"
@onready var weight = $"weight"
@onready var audio = $"audio"
@onready var reel_light = $"reel_light"
@onready var symbol_light = $"symbol_light"
@onready var order_navi = $"order_navi"
@onready var display = $"display"

@onready var frame_lights: Array = [
	$frame_light/L_reel_light,
	$frame_light/C_reel_light,
	$frame_light/R_reel_light,
	$frame_light/all_reel_light
]

var rare_flag = sub.rare_flags

var current_RT: String = "RT0"
var RT_game: int
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

var display_scene_path: String
var order_scene_path: String

var display_node: Node = null
var order_node: Node = null

signal medal_bet()
signal main_flag(value)
signal jac_count()
signal bonus_end()
signal prized()

func _ready():
	display_scene_path = sub.display_scene_path
	order_scene_path = sub.order_scene_path
	effects_rands.resize(256)
	effect_slot = sub.effect_slot

	if mainROM:
		connect_to_mainROM()

	if order_scene_path:
		var order_scene = load(order_scene_path)
		var scene = order_scene.instantiate()
		order_navi.add_child(scene)
		order_node = scene
		connect_to_order(order_node)

	if display_scene_path:
		var display_scene = load(display_scene_path)
		var scene = display_scene.instantiate()
		display.add_child(scene)
		display_node = scene
		connect_to_display(display_node)

func connect_to_mainROM():
	if mainROM.has_signal("bonus_est"):
		mainROM.bonus_est.connect(_on_bonus_est)
	if mainROM.has_signal("bonus_prized"):
		mainROM.bonus_prized.connect(_on_bonus_prized)
	if mainROM.has_signal("bonus_end"):
		mainROM.bonus_end.connect(_on_bonus_end)
	if mainROM.has_signal("medal_bet"):
		mainROM.medal_bet.connect(_on_medal_bet)
	if mainROM.has_signal("maxbet_pushed"):
		mainROM.maxbet_pushed.connect(_on_maxbet_pushed)
	if mainROM.has_signal("flag"):
		mainROM.flag.connect(_on_flag)
	if mainROM.has_signal("spin_start"):
		mainROM.spin_start.connect(_on_spin_start)
	if mainROM.has_signal("reel_stopped"):
		mainROM.reel_stopped.connect(_on_reel_stopped)
	if mainROM.has_signal("now_RT"):
		mainROM.now_RT.connect(_on_now_RT)
	if mainROM.has_signal("last_RT"):
		mainROM.last_RT.connect(_on_last_RT)
	if mainROM.has_signal("JAC_IN"):
		mainROM.JAC_IN.connect(_on_JAC_IN)
	if mainROM.has_signal("prized_role"):
		mainROM.prized_role.connect(_on_prized_role)
	if mainROM.has_signal("prized_array"):
		mainROM.prized_array.connect(_on_prized_array)

func connect_to_order(node):
	if mainROM.has_signal("medal_bet") and node.has_method("_on_medal_bet"):
		mainROM.medal_bet.connect(node._on_medal_bet)
	if mainROM.has_signal("maxbet_pushed") and node.has_method("_on_maxbet_pushed"):
		mainROM.maxbet_pushed.connect(node._on_maxbet_pushed)
	if mainROM.has_signal("flag") and node.has_method("_on_flag"):
		mainROM.flag.connect(node._on_flag)
	if mainROM.has_signal("now_RT") and node.has_method("_on_now_RT"):
		mainROM.now_RT.connect(node._on_now_RT)
	if mainROM.has_signal("prized_role") and node.has_method("_on_prized"):
		mainROM.prized_role.connect(node._on_prized)
	if mainROM.has_signal("stop_button") and node.has_method("_on_stop_button"):
		mainROM.stop_button.connect(node._on_stop_button)

func connect_to_display(node):
	if mainROM.has_signal("medal_bet") and node.has_method("_on_medal_bet"):
		mainROM.medal_bet.connect(node._on_medal_bet)
	if mainROM.has_signal("bonus_est") and node.has_method("_on_bonus_est"):
		mainROM.bonus_est.connect(node._on_bonus_est)
	if mainROM.has_signal("bonus_prized") and node.has_method("_on_bonus_prized"):
		mainROM.bonus_prized.connect(node._on_bonus_prized)
	if mainROM.has_signal("prized_role") and node.has_method("_on_prized"):
		mainROM.prized_role.connect(node._on_prized)

func _on_spin_start():
	var track = weight.random_SE("reel_start")
	audio.play_spin_start(track)

func _on_JAC_IN():
	jac_counter += 1

	if jac_counter >= 2:
		print(jac_counter)
		audio.update_bonus_music(current_bonus)

func _on_flag(value):
	result_flag = value
	effects_seeds = mainROM.effects_seeds
	drawing_hash_array(effects_seeds)

func _on_prized_role(value):
	if value:
		prized_role = value["name"]
		audio.play_prized(value["name"])
	else:
		prized_role = ""

func _on_prized_array(value):
	var current_reel_grid = mainROM.current_reel_grid
	# reel_light.replay_flash()
	# symbol_light.middle_flash(current_reel_grid)

func _on_bonus_est(value):
	bonus_state = value
	print("effects.gd", bonus_state)
	if display_node and display_node.has_method("_on_bonus_est"):
		display_node._on_bonus_est(value)

func _on_bonus_prized(value):
	current_bonus = value
	bonus_state = null
	if display_node and display_node.has_method("_on_bonus_prized"):
		display_node._on_bonus_prized(value)
	if value != "None":
		audio.play_bonus(value)
	if value == "None":
		print("bonus_end: effects")
		jac_counter = 0

func _on_bonus_end(value):
	if value != "None":
		audio.end_bonus(value)
	current_bonus = "None"

func _on_medal_bet(value):
	audio.play_bet(value)
	reel_light.stop_flash()
	symbol_light.stop_flash()
	medal_bet.emit()

func _on_maxbet_pushed():
	audio.play_maxbet()

func _on_reel_stopped(reel_pos, stopped_reel, _current_reel_grid):
	current_reel = stopped_reel
	audio.play_reel_stop(reel_pos)

	if order_node and order_node.has_method("_on_reel_stopped"):
		order_node._on_reel_stopped(reel_pos, stopped_reel, _current_reel_grid)

func _on_now_RT(value):
	current_RT = value

func _on_last_RT(value):
	RT_game = value
	

func get_effect_rand(key):

	var slot = effect_slot.get(key, -1)

	if slot == -1:
		push_error("指定されたキーが存在しません:", key)
		return 256

	return effects_rands[slot]


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
	
