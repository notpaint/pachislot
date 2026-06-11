extends Node2D

@onready var grid = [
    [$L_upper, $C_upper, $R_upper],
    [$L_middle, $C_middle, $R_middle],
    [$L_lower, $C_lower, $R_lower]
]

var flash_tween: Tween

func _ready():
    stop_flash()

func flash_all():
    if flash_tween:
        flash_tween.kill()
    flash_tween = create_tween().set_loops()
    for rect in get_children():
        flash_tween.parallel().tween_property(rect, "color:a", 0.7, 1).set_trans(Tween.TRANS_CUBIC)
    flash_tween.tween_interval(0.5)
    for rect in get_children():
        flash_tween.parallel().tween_property(rect, "color:a", 0.0, 1).set_trans(Tween.TRANS_CUBIC)
    flash_tween.tween_interval(0.5)


func stop_flash():
    if flash_tween:
        flash_tween.kill()

    for rect in get_children():
        rect.color = Color(0, 0, 0, 0)