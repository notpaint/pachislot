extends Node2D

const loop_duration: int = 458752

var current_value:float = 0.0
var ratio:float = 0.0
var result_value:int = 0

var flags = {}

func _ready():
	var f = FileAccess.open("res://flags_test.csv", FileAccess.READ)
	var line = f.get_csv_line()
	line = f.get_csv_line()
	while line.size() >= 3:
		var key = line[0]
		var weights = line.slice(1)
		flags[key] = weights
		line = f.get_csv_line()
	var x = flags.values()

func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_SPACE:
			drawing()
			print(role(result_value))
		if event.keycode == KEY_ENTER:
			pass

func drawing():
	var current_time = Time.get_ticks_usec()
	current_value = current_time % loop_duration
	ratio = float(current_value) / float(loop_duration)
	result_value = int(ratio * 65536)

func role(value):
	var number = value
	
	for key in flags:
		var weight_array = flags[key]
		var weight = weight_array[0].to_int()
		number -= weight
		if number < 0:
			return key
	return "vac"
		
