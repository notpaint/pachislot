extends AudioStreamPlayer

var bonus_music: Dictionary = {}

var in_bonus : bool = false
var first_bet : bool = true

var current_bonus: String
var current_playing: String = ""

func _ready():
	finished.connect(_on_finished)
	bonus_music = sub.bonus_music

func _on_finished():
	if current_playing == "start":
		var loop_path = bonus_music["RB"]["tracks"]["main"]["loop"]
		if loop_path:
			current_playing = "loop"
			stream = load(loop_path)
			play()


func bonus_prized(value):
	if value != "None":
		in_bonus = true
		var jingle_path = bonus_music[value]["jingle"]
		current_bonus = value
		if jingle_path:
			stream = load(jingle_path)
			play()
		else:
			start_music()
			

func start_music():
	if current_bonus == "RB":
		var start_path = bonus_music["RB"]["tracks"]["main"]["start"]
		if start_path:
			current_playing = "start"
			stream = load(start_path)
			play()
	

			


# func medal_bet(value):
#     print(value)
#     if in_bonus:
#         if first_bet:
#             first_bet = false
#             stream = RB
#             play()
