extends Node

@onready var effects = $".."
@onready var bonus = $"bonus"

var expression = Expression.new()
var bonus_music: Dictionary = {}

var in_bonus: bool = false
var first_bet: bool = true

var current_bonus: String

func _ready():
	bonus_music = sub.bonus_music

func play_bonus(value):
	if value != "None":
		var bonus_rules = bonus_music[value]["rule"]
		var bonus_track = get_start_track(bonus_rules)
		print(bonus_track)

func get_start_track(rules):
	rules.sort_custom(sort_rules)
	for rule in rules:
		var cond = rule["cond"]
		
		if cond == "default":
			return rule["track"]
		
		expression.parse(cond, ["now_RT"])
		if expression.execute([effects.now_RT]) == true:
			return rule["track"]

		


func sort_rules(a, b):
	return a["priority"] > b["priority"]
