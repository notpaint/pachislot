extends Node

@onready var effects = $".."

var SE_dict: Dictionary = {}
var bonus_music: Dictionary = {}
var back_music: Dictionary = {}

var effect_slot: Dictionary = {}

var in_bonus: bool = false
var first_bet: bool = true

func _ready():
	load_SE_dict()
	load_music()

func sort_rules(a, b):
	return a["priority"] > b["priority"]

func load_SE_dict():
	SE_dict = sub.SE_dict.duplicate(true)

	for item in SE_dict:
		var SE_rules = SE_dict[item]["rule"]
		SE_rules.sort_custom(sort_rules)

		for track_name in SE_dict[item]["sound"]:
			var path = SE_dict[item]["sound"][track_name]
			if path:
				SE_dict[item]["sound"][track_name] = load(path)

func load_music():
	bonus_music = sub.bonus_music.duplicate(true)

	for item in bonus_music:
		var bonus_rules = bonus_music[item]["rule"]
		bonus_rules.sort_custom(sort_rules)

		var tracks = bonus_music[item]["tracks"]
		for track_name in bonus_music[item]["tracks"]:
			var track_info = tracks[track_name]
			if track_info.get("start"):
				track_info["start"] = load(track_info["start"])
			if track_info.get("end"):
				track_info["end"] = load(track_info["end"])

	back_music = sub.back_music.duplicate(true)

	for item in back_music:
		var path = back_music[item]
		if path != "":
			back_music[item] = load(path)

func random_SE(event):
	var SE_rules = SE_dict[event]["rule"]
	var SE_track = get_track(SE_rules, event)
	return(SE_track)


func get_track(rules, event, variant: String = "default"):

	var rule = get_rule(rules, event, variant)
	return rule["track"]

func get_rule(rules, event, variant: String = "default"):
	for rule in rules:
		var cond = rule["cond"]
		if cond == variant:
			return rule

		var expression = rule["parsed"]
		if expression.execute([], effects) == true:
			if rule.has("weight"):
				var weight = rule["weight"]
				var rand_number = effects.get_effect_rand(event)

				if rand_number < weight:
					return rule
				else:
					return return_default_rule(rules, variant)
			else:
				return rule
				


func return_default_rule(rules, variant: String = "default"):
	for rule in rules:
		if rule["cond"] == variant:
			return rule
				
func get_track_array(trigger: String = "default"):
	for data in back_music:
		if not data.has("parsed"):
			continue
		
		var expression = data["parsed"]
		if expression.execute([trigger], effects):
			return data

	for data in back_music:
		if not data.has("parsed"):
			return data

	return null
