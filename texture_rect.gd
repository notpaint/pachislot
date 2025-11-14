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
				pass
			else: 
				is_scrolling = true
		if event.keycode == KEY_ENTER:
			if is_scrolling:
				stop_reel()
			else:
				pass
				
func stop_reel():
	#is_scrolling = false
	if active_tween:
		active_tween.kill()
	var current_offset:float = fmod((abs(scroll_offset) / pattern_per), 1)
	if current_offset < 0.3:
		return
	var target_offset:float = (floor(scroll_offset / pattern_per) * pattern_per) - 0.2
	var target_speed:float = abs(target_offset - scroll_offset) / scroll_speed * -1.0
	active_tween = create_tween()
	active_tween.tween_callback(set.bind("is_scrolling", false))
	active_tween.tween_property(self, "scroll_offset", target_offset, target_speed)
	await active_tween.finished
	scroll_offset = fmod(scroll_offset, 1.0)
	if active_tween:
		active_tween.kill
	print(target_speed)
	
	
