extends Node

@onready var effects = $".."
@onready var weight = $"../weight"
@onready var SE = $"SE"
@onready var bonus = $"bonus"

var SE_dict: Dictionary = {}
var bonus_music: Dictionary = {}
var music_rules: Dictionary = {}

var in_bonus: bool = false
var first_bet: bool = true

var current_bonus: String

func _ready():
	SE_dict = weight.SE_dict
	bonus_music = sub.bonus_music
	music_rules = sub.music_rules


func play_bet(value):
	if value != 0:
		var bet_rules = SE_dict["bet"]["rule"]
		var bet_track = get_track(bet_rules)
		var bet_stream = SE_dict["bet"]["sound"][bet_track]
		if bet_stream:
			SE.stream = bet_stream
			SE.play()


func play_reel_stop():
	var stop_rules = SE_dict["reel_stop"]["rule"]
	var stop_track = get_track(stop_rules)
	var stop_stream = SE_dict["reel_stop"]["sound"][stop_track]
	if stop_stream:
		SE.stream = stop_stream
		SE.play()


func play_spin_start(track):
	var start_stream = SE_dict["reel_start"]["sound"][track]
	if start_stream:
		SE.stream = start_stream
		SE.play()

func play_prized(value):
	var start_rules = SE_dict["prized"]["rule"]
	var start_track = get_track(start_rules)
	var start_stream = SE_dict["prized"]["sound"][start_track]
	if start_stream:
		SE.stream = start_stream
		SE.play()

func get_bonus_music_path(value):
	if value != "None":
		var current_bonus_music = bonus_music[value]
		var current_part = 1
		var bonus_rules = music_rules[value]
		var bonus_track = get_track(bonus_rules)

		var jingle_path = current_bonus_music[bonus_track][current_part]["jingle"]

		if jingle_path:
			bonus.stream = load(jingle_path)
			bonus.play()

			await effects.medal_bet

func play_bonus(value):
	if value != "None":
		var current_bonus_music = bonus_music[value]
		var jingle_path = current_bonus_music["jingle"]

		var bonus_rules = current_bonus_music["rule"]
		var bonus_track = get_track(bonus_rules)
		var start_path = current_bonus_music["tracks"][bonus_track]["start"]
		var next_track = current_bonus_music["tracks"][bonus_track]["next"]
		var end_path: String

		if jingle_path:
			bonus.stream = load(jingle_path)
			bonus.play()

			await effects.medal_bet

		if start_path:
			bonus.stream = load(start_path)
			bonus.play()

			if next_track:
				var part2_path = current_bonus_music["tracks"][next_track]["start"]

				await effects.jac_count

				bonus.stream = load(part2_path)
				bonus.play()
				end_path = current_bonus_music["tracks"][next_track]["end"]
				await effects.bonus_end
			else:
				end_path = current_bonus_music["tracks"][bonus_track]["end"]
				await effects.bonus_end

		if end_path:
			bonus.stream = load(end_path)
			bonus.play()
		else:
			bonus.stop()
		

func get_track(rules):
	for rule in rules:
		var cond = rule["cond"]
		
		if cond == "default":
			return rule["track"]

		var expression = rule["parsed"]
		if expression.execute([], effects) == true:
			return rule["track"]

		