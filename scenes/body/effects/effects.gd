extends Node

@onready var mainROM = $"../mainROM"
@onready var audio = $"audio"
@onready var frame_light = $"frame_light"
@onready var order_navi = $"order_navi"
@onready var reel_light = $"reel_light"

var now_RT = false
var current_bonus = "None"

var current_reel

var jac_counter: int = 0

signal medal_bet()
signal jac_count()
signal bonus_end()

func _ready():
	if mainROM:
		if mainROM.has_signal("bonus_est"):
			mainROM.bonus_est.connect(_on_bonus_est)
		if mainROM.has_signal("bonus_prized"):
			mainROM.bonus_prized.connect(_on_bonus_prized)
		if mainROM.has_signal("medal_bet"):
			mainROM.medal_bet.connect(_on_medal_bet)
		if mainROM.has_signal("spin_start"):
			mainROM.spin_start.connect(_on_spin_start)
		if mainROM.has_signal("reel_stopped"):
			mainROM.reel_stopped.connect(_on_reel_stopped)
		if mainROM.has_signal("now_RT"):
			mainROM.now_RT.connect(_on_now_RT)
		if mainROM.has_signal("JAC_IN"):
			mainROM.JAC_IN.connect(_on_JAC_IN)
	reel_light.v_flash()


func _on_spin_start():
	audio.play_spin_start()


func _on_JAC_IN():
	jac_counter += 1
	if jac_counter == 3:
		jac_count.emit()

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
	medal_bet.emit()
	pass
	# medal_bet.emit(value)

func _on_reel_stopped(value):
	current_reel = value
	audio.play_reel_stop()

func _on_now_RT(value):
	if value == "RT3":
		now_RT = true
	elif value == "RT0":
		now_RT = false
