extends Node2D

@onready var L_reel = $"L_reel"
@onready var C_reel = $"C_reel"
@onready var R_reel = $"R_reel"

@onready var reel_array = [L_reel, C_reel, R_reel]

var stopped_count: int = 0

var navi_miss: bool = false

func _ready():
	clear_navi()

func clear_navi():
	L_reel.text = ""
	C_reel.text = ""
	R_reel.text = ""

	navi_miss = false
	stopped_count = 0

func set_navi(value):
	L_reel.text = str(value[0]) if value[0] != null else ""
	C_reel.text = str(value[1]) if value[1] != null else ""
	R_reel.text = str(value[2]) if value[2] != null else ""

func push_navi(reel_pos):

	stopped_count += 1

	if reel_array[reel_pos].text != "":
		var navi_number = int(reel_array[reel_pos].text)
		if navi_number != stopped_count:
			navi_miss = true

	if not navi_miss:
		reel_array[reel_pos].text = ""

	if stopped_count >= 3:
		clear_navi()
