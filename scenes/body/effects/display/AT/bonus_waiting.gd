extends Control

@onready var kaku = $"kaku"
@onready var tei = $"tei"
@onready var bonus = $"bonus"
@onready var preparing = $"preparing"

var label_length: int = 1312
var scroll_speed: float = 60.0

var kaku_pos_x: Array = [Vector2(475.0, 32.0)]
var tei_pos_x: Array = [Vector2(642.0, 31.5)]

var l_tween: Tween
var r_tween: Tween

var bonus_tween: Tween

var waiting: bool = false

func _ready() -> void:
	initialize()

func _process(delta: float) -> void:
	if not waiting:
		return
	preparing.position.x += scroll_speed * delta
	if preparing.position.x >= 0:
		preparing.position.x -= 1312
	
func initialize() -> void:
	kaku.position = Vector2(-150.0, 32.0)
	tei.position = Vector2(1260, 31.5)
	bonus.position = Vector2(132.0, 32.0)
	bonus.scale = Vector2(0, 0)
	preparing.visible = false

func first_part():
	if l_tween:
		l_tween.kill()
	if r_tween:
		r_tween.kill()
	
	l_tween = create_tween()
	l_tween.tween_property(kaku, "position:x", 475, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	r_tween= create_tween()
	r_tween.tween_property(tei, "position:x", 642, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(0.8).timeout

	second_part()


func second_part():
	if l_tween:
		l_tween.kill()
	if r_tween:
		r_tween.kill()
	
	l_tween = create_tween()
	l_tween.tween_property(kaku, "position:x", 768, 0.2)
	r_tween= create_tween()
	r_tween.tween_property(tei, "position:x", 937, 0.2)

	if bonus_tween:
		bonus_tween.kill()
	
	bonus_tween = create_tween()
	bonus_tween.tween_property(bonus, "scale", Vector2(1, 1), 0.2)

	await get_tree().create_timer(2.0).timeout

	third_part()


func third_part():
	initialize()

	preparing.visible = true
	waiting = true
