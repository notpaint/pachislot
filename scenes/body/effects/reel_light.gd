extends Node2D

@onready var grid = [
	[$L_upper, $C_upper, $R_upper],
	[$L_middle, $C_middle, $R_middle],
	[$L_lower, $C_lower, $R_lower]
]

var flash_tween: Tween

func _ready():
	stop_flash()

func middle_flash():
	if flash_tween:
		flash_tween.kill()

	var target = [grid[0][0], grid[0][1], grid[0][2], grid[2][0], grid[2][1], grid[2][2]]

	flash_tween = create_tween().set_parallel(true)

	for rect in target:
		flash_tween.tween_property(rect, "color:a", 0.3, 0.5)
	
	flash_tween.chain()

	for rect in target:
		flash_tween.tween_property(rect, "color:a", 0.0, 0.5)

func replay_flash():
	if flash_tween:
		flash_tween.kill()

	flash_tween = create_tween().set_parallel(true)

	for rect in get_children():
		flash_tween.tween_property(rect, "color:a", 0.3, 0.3).set_trans(Tween.TRANS_CUBIC)

	flash_tween.chain()

	for rect in get_children():
		flash_tween.tween_property(rect, "color:a", 0.0, 0.3).set_trans(Tween.TRANS_CUBIC)

func v_flash():
	if flash_tween:
		flash_tween.kill()
	
	var target = [grid[0][0], grid[1][0], grid[2][1], grid[1][2], grid[0][2]]
	var delay_time = 0.0

	flash_tween = create_tween().set_loops().set_parallel(true)

	lights_out()

	for rect in target:
		flash_tween.tween_property(rect, "color:a", 0.0, 0.5).set_delay(delay_time)
		delay_time += 0.1
	
	flash_tween.chain()

	# for rect in target:
	# 	flash_tween.parallel().tween_property(rect, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_CUBIC)

	# flash_tween.tween_interval(0.2)

	for rect in target:
		flash_tween.tween_property(rect, "color:a", 0.7, 0.5).set_trans(Tween.TRANS_CUBIC)


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

func lights_up():
	for row in grid.slice(1):
		for rect in row:
			rect.color.a = 0.7


func lights_out():
	for rect in get_children():
		rect.color.a = 0.7

func stop_flash():
	if flash_tween:
		flash_tween.kill()

	for rect in get_children():
		rect.color.a = 0.0
