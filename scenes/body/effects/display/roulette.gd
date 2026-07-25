extends Control

@onready var first = $"first"
@onready var loop = $"loop"

var first_pos = 39
var pospos = -429
var pattern_gap = 236

var reel_length: int = 609

var rotate = false

var first_poses: Array = [-433, -197, 39]
var spin_speed: float = 0.0
var max_spin_speed: float = 2500

var first_tween: Tween


func _ready() -> void:
	first.visible = true
	loop.visible = false

	await get_tree().create_timer(0.3).timeout
	await first_rotate()
		
	first.visible = false
	loop.visible = true
	rotate = true



func _process(delta: float) -> void:
	if not rotate:
		return
	spin_speed = move_toward(spin_speed, max_spin_speed, 15000 * delta)
	loop.position.y += spin_speed * delta
	if loop.position.y >= 708:
		loop.position.y -= 708


func first_rotate():
	if first_tween:
		first_tween.kill()

	first_tween = create_tween()

	for y in first_poses:
		first_tween.tween_property(first, "position:y", y, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		first_tween.tween_interval(0.3)

	await first_tween.finished
