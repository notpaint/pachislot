extends Node2D

const loop_duration: int = 458752

var current_value:float = 0.0
var ratio:float = 0.0
var result_value:int = 0

func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_SPACE:
			pass
		if event.keycode == KEY_ENTER:
			drawing()
			print(current_time)
			
func drawing():
	var current_time = Time.get_ticks_usec()
	current_value = current_time % loop_duration
	ratio = float(current_value) / float(loop_duration)
	result_value = int(ratio * 65536)
