extends Node2D

@onready var L_reel = $"L_reel"
@onready var C_reel = $"C_reel"
@onready var R_reel = $"R_reel"

@onready var effects = $".."

@onready var reel_array = [L_reel, C_reel, R_reel]

var stopped_count: int = 0

var current_frame_color: Color
var current_number_color: Color

var navi_miss: bool = false

func _ready():
	clear_navi()

func clear_navi():
	L_reel.text = ""
	C_reel.text = ""
	R_reel.text = ""

	navi_miss = false
	stopped_count = 0


func set_navi(order, frame_color: Color = Color.WHITE, number_color: Color = Color.WHITE):

	L_reel.text = str(order[0]) if order[0] != null else ""
	C_reel.text = str(order[1]) if order[1] != null else ""
	R_reel.text = str(order[2]) if order[2] != null else ""

	current_frame_color = frame_color
	current_number_color = number_color

	for label in reel_array:
		label.label_settings.font_color = number_color

	for i in range(3):
		if order[i] == 1:
			frame_light_on(i, frame_color)


func frame_light_on(reel_pos, color):
	var pos = effects.frame_lights[reel_pos]
	pos.visible = true
	pos.default_color = color

func frame_light_off(reel_pos):
	var pos = effects.frame_lights[reel_pos]
	pos.visible = false


func push_navi(reel_pos):

	stopped_count += 1

	if reel_array[reel_pos].text != "":
		var navi_number = int(reel_array[reel_pos].text)
		if navi_number != stopped_count:
			navi_miss = true

	if not navi_miss:
		reel_array[reel_pos].text = ""
		frame_light_off(reel_pos)

		for i in range(3):
			if stopped_count + 1 == int(reel_array[i].text):
				frame_light_on(i, current_frame_color)

