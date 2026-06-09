extends Node

@onready var mainROM = $"../mainROM"
@onready var audio = $"audio"
@onready var reel_light = $"reel_light"
@onready var order_navi = $"order_navi"

var now_RT = false

func _ready():
	if mainROM:
		if mainROM.has_signal("bonus_est"):
			mainROM.bonus_est.connect(_on_bonus_est)
		if mainROM.has_signal("bonus_prized"):
			mainROM.bonus_prized.connect(_on_bonus_prized)
		if mainROM.has_signal("medal_bet"):
			mainROM.medal_bet.connect(_on_medal_bet)
		if mainROM.has_signal("reel_stopped"):
			mainROM.reel_stopped.connect(_on_reel_stopped)
		if mainROM.has_signal("now_RT"):
			mainROM.now_RT.connect(_on_now_RT)


func _on_bonus_est(value):
	pass

func _on_bonus_prized(value):
	audio.play_bonus(value)

func _on_medal_bet(value):
	pass
	# medal_bet.emit(value)

func _on_reel_stopped(value):
	print(value)

func _on_now_RT(value):
	if value == "RT3":
		now_RT = true
	elif value == "RT0":
		now_RT = false
