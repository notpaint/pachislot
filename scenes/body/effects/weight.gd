extends Node

@onready var effects = $".."

var SE_dict: Dictionary = {}
var bonus_music: Dictionary = {}
var effect_slot: Dictionary = {}

var in_bonus: bool = false
var first_bet: bool = true

func _ready():
	load_SE_dict()
	load_bonus_music()

func sort_rules(a, b):
	return a["priority"] > b["priority"]

func load_SE_dict():
	SE_dict = sub.SE_dict.duplicate(true)
	for item in SE_dict:
		var SE_rules = SE_dict[item]["rule"]
		SE_rules.sort_custom(sort_rules)
		for rule in SE_rules:
			if rule["cond"] != "default":
				var expr = Expression.new()
				expr.parse(rule["cond"])
				rule["parsed"] = expr
		for track_name in SE_dict[item]["sound"]:
			var path = SE_dict[item]["sound"][track_name]
			if path:
				SE_dict[item]["sound"][track_name] = load(path)

func load_bonus_music():
	bonus_music = sub.bonus_music.duplicate(true)
	for value in bonus_music:
		var bonus_rules = bonus_music[value]["rule"]
		for rule in bonus_rules:
			if rule["cond"] != "default":
				var expr = Expression.new()
				expr.parse(rule["cond"])
				rule["parsed"] = expr


func random_SE(event):
	var SE_rules = SE_dict[event]["rule"]
	var SE_track = get_track(SE_rules, event)
	return(SE_track)


func get_track(rules, event, variant: String = "default"):
	for rule in rules:
		var cond = rule["cond"]
		
		if cond == variant:
			return rule["track"]

		var expression = rule["parsed"]
		if expression.execute([], effects) == true:

			if rule.has("weight"):
				var weight = rule["weight"]
				var rand_slot = effects.effect_slot[event]
				var rand_number = effects.effects_rands[rand_slot]

				if rand_number < weight:
					return rule["track"]
				else:
					return return_default(rules, variant)


func return_default(rules, variant: String = "default"):
	for rule in rules:
		if rule["cond"] == variant:
			return rule["track"]
				