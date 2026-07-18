extends Control

@onready var shatter_l: Sprite2D = $"shatter_l"
@onready var shatter_r: Sprite2D = $"shatter_r"

@onready var display_node: Node

var l_pos_x: Array = [-807, -597, -387, -177]
var r_pos_x: Array = [1260, 1050, 840, 630]

var l_tween: Tween
var r_tween: Tween



signal shatter_closed()


func _ready() -> void:
	shatter_l.position.x = l_pos_x[0]
	shatter_r.position.x = r_pos_x[0]

func in_bonus_shatter():
	await close_shatter()

	move_left(3, 2, 0.3)
	await move_right(3, 2, 0.3)
	await get_tree().create_timer(0.2).timeout

	move_left(2, 0, 0.3)
	await move_right(2, 0, 0.3)
	await get_tree().create_timer(0.2).timeout


func close_shatter():
	for n in [l_tween, r_tween]: if n: n.kill()

	l_tween = create_tween()
	r_tween = create_tween()
	
	l_tween.tween_property(shatter_l, "position:x", l_pos_x[3], 0.1)
	r_tween.tween_property(shatter_r, "position:x", r_pos_x[3], 0.1)

	r_tween.tween_callback(func(): shatter_closed.emit())

	await r_tween.finished


func shake_shatter():
	for n in [l_tween, r_tween]: if n: n.kill()


func move_left(first_pos:int, second_pos: int, duration: float = 0.5):
	if l_tween:
		l_tween.kill()

	shatter_l.position.x = l_pos_x[first_pos]
	l_tween = create_tween()
	l_tween.tween_property(shatter_l, "position:x", l_pos_x[second_pos], duration)

	await l_tween.finished

func move_right(first_pos:int, second_pos: int, duration: float = 0.5):
	if r_tween:
		r_tween.kill()

	shatter_r.position.x = r_pos_x[first_pos]
	r_tween = create_tween()
	r_tween.tween_property(shatter_r, "position:x", r_pos_x[second_pos], duration)

	await r_tween.finished
