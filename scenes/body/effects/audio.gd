extends Node

@onready var mainROM =$"../../mainROM"
@onready var effects = $".."
@onready var weight = $"../weight"
@onready var SE = $"SE"
@onready var medal = $"medal"
@onready var bonus = $"bonus"
@onready var reel = [$"left", $"center", $"right"]


var SE_dict: Dictionary = {}
var bonus_music: Dictionary = {}

var in_bonus: bool = false
var first_bet: bool = true

var current_bonus: String
var current_bonus_track: String
var current_bonus_path: String

var current_music_path: String

func _ready():
	SE_dict = weight.SE_dict
	bonus_music = weight.bonus_music

func play_bet(value):
	if value != 0:
		var bet_rules = SE_dict["bet"]["rule"]
		var bet_track = weight.get_track(bet_rules, "bet")
		var bet_stream = SE_dict["bet"]["sound"][bet_track]
		if bet_stream:
			if SE.playing:
				return
			medal.stream = bet_stream
			medal.play()

func play_reel_stop(reel_pos):
	var stop_rules = SE_dict["reel_stop"]["rule"]
	var stop_track = weight.get_track(stop_rules, "reel_stop")
	var stop_stream = SE_dict["reel_stop"]["sound"][stop_track]
	if stop_stream:
		var player = reel[reel_pos]
		player.stream = stop_stream
		player.play()


func play_spin_start(track):
	var start_stream = SE_dict["reel_start"]["sound"][track]
	if start_stream:
		SE.stream = start_stream
		SE.play()

func play_prized(value):
	var start_rules = SE_dict["prized"]["rule"]
	var start_track = weight.get_track(start_rules, "prized")
	var start_stream = SE_dict["prized"]["sound"][start_track]
	if start_stream:
		SE.stream = start_stream
		SE.play()

func play_bonus(value):
	if value != "None":
		var current_bonus_music = bonus_music[value]
		var jingle_path = current_bonus_music["jingle"]

		var bonus_rules = current_bonus_music["rule"]
		var bonus_track = weight.get_track(bonus_rules, value)
		current_bonus_track = bonus_track

		var start_path = current_bonus_music["tracks"][bonus_track]["start"]
		current_bonus_path = start_path

		if jingle_path:
			bonus.stream = load(jingle_path)
			bonus.play()

			mainROM.bet_block += 1
			await bonus.finished
			mainROM.bet_block -= 1

			await effects.medal_bet

		if start_path:
			bonus.stream = load(start_path)
			bonus.play()
			

func update_bonus_music(value):
	if value != "None":
		print(value)
		var current_bonus_music = bonus_music[value]
		var bonus_rules = current_bonus_music["rule"]
		var bonus_track = weight.get_track(bonus_rules, value)
		var start_path = current_bonus_music["tracks"][bonus_track]["start"]

		if current_bonus_path != start_path:
			current_bonus_path = start_path
			current_bonus_track = bonus_track
			bonus.stream = load(start_path)
			bonus.play()


func end_bonus(value):
	if value != "None":
		var current_bonus_music = bonus_music[value]
		var end_path = current_bonus_music["tracks"][current_bonus_track]["end"]

		if end_path:
			bonus.stream = load(end_path)
			bonus.play()

			mainROM.bet_block += 1
			await bonus.finished
			mainROM.bet_block -= 1
		else:
			bonus.stop()


func back_music(trigger: String = "default"):
	var music_data = weight.get_track_array(trigger)
	if music_data:
		var music_path = music_data["path"]
		if music_path == "silent":
			if current_music_path != "":
				current_music_path = ""
				bonus.stop()
		elif music_path != "":
			if current_music_path != music_path:
				current_music_path = music_path
				bonus.stream = load(music_path)
				bonus.play()

				if music_data["bet_block"]:
					mainROM.bet_block += 1
					await bonus.finished
					mainROM.bet_block -= 1
