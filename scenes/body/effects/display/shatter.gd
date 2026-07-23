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
	# shatter_l.position.x = l_pos_x[0]
	shatter_r.position.x = r_pos_x[0]


func in_bonus_shatter():

	await move_shatter("both", 0, 3, 0.2)

	shatter_closed.emit()

	await move_shatter("both", 3, 2, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)

	await move_shatter("both", 2, 0, 0.5, Tween.TRANS_QUART, Tween.EASE_IN)




func close_shatter():
	for n in [l_tween, r_tween]: if n: n.kill()

	await move_shatter("both", 0, 3, 0.2)


func move_shatter(
	side: String,
	first_index: int,
	second_index: int,
	duration: float = 0.5,
	trans_type: Tween.TransitionType = Tween.TRANS_LINEAR,
	ease_type: Tween.EaseType = Tween.EASE_OUT
):
	match side:
		"left":
			l_tween = animate_shatter(shatter_l, l_tween, l_pos_x, first_index, second_index, duration, trans_type, ease_type)
			if l_tween:
				await l_tween.finished
		"right":
			r_tween = animate_shatter(shatter_r, r_tween, r_pos_x, first_index, second_index, duration, trans_type, ease_type)
			if r_tween:
				await r_tween.finished
		"both":
			l_tween = animate_shatter(shatter_l, l_tween, l_pos_x, first_index, second_index, duration, trans_type, ease_type)
			r_tween = animate_shatter(shatter_r, r_tween, r_pos_x, first_index, second_index, duration, trans_type, ease_type)
			if r_tween:
				await r_tween.finished


func animate_shatter(
	target: Sprite2D,
	tween: Tween,
	pos_array: Array,
	first_index: int,
	second_index: int,
	duration: float,
	trans_type: Tween.TransitionType,
	ease_type: Tween.EaseType
) -> Tween:

	if tween:
		tween.kill()


	target.position.x = pos_array[first_index]
	var new_tween = create_tween()
	new_tween.tween_property(target, "position:x", pos_array[second_index], duration).set_trans(trans_type).set_ease(ease_type)


	return new_tween


func move_left(first_pos:int, second_pos: int, duration: float = 0.5):
	if l_tween:
		l_tween.kill()

	shatter_l.position.x = l_pos_x[first_pos]
	l_tween = create_tween()
	l_tween.tween_property(shatter_l, "position:x", l_pos_x[second_pos], duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	await l_tween.finished


func move_right(first_pos:int, second_pos: int, duration: float = 0.5):
	if r_tween:
		r_tween.kill()

	shatter_r.position.x = r_pos_x[first_pos]
	r_tween = create_tween()
	r_tween.tween_property(shatter_r, "position:x", r_pos_x[second_pos], duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)


	await r_tween.finished
