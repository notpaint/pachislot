extends TextureRect 

const pattern_sum: int = 5
const pattern_per: float = 1.0 / float(pattern_sum)

@export var scroll_speed: float = -1.0

var scroll_offset: float = 0.0
var is_scrolling: bool = false
var active_tween : Tween

func _process(delta:float):
	if is_scrolling:
		scroll_offset += scroll_speed * delta
		scroll_offset = fmod(scroll_offset, 1.0)
	if material:
		material.set_shader_parameter("scroll_offset", scroll_offset)
		
func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			if is_scrolling:
				is_scrolling = false
				var center_uv:float = fmod(scroll_offset + 0.5 , 1.0)
				if center_uv < 0.0:
					center_uv += 1.0
				var current_index: int = int(floor(center_uv / pattern_per))
				var pattern_number:int = current_index + 1
				print(pattern_number)
			else: 
				is_scrolling = true
				
