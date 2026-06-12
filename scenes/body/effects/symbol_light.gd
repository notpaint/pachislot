extends Node2D

@onready var effects = $".."

@onready var grid = [
	[$L_upper, $C_upper, $R_upper],
	[$L_middle, $C_middle, $R_middle],
	[$L_lower, $C_lower, $R_lower]
]

var flash_tween: Tween

func v_flash(value):
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween().set_loops().set_parallel(true)

	for y in range(3):
		for x in range(3):
			var symbol = value[x][y]
			if symbol:
				var path = "res://assets/images/symbol_docs/" + symbol + ".png"
				grid[x][y].texture = load(path)

			grid[x][y].material.set_shader_parameter("flash_amount", 0.0)
	
	for y in range(3):
		for x in range(3):
			flash_tween.tween_property(grid[y][x].material, "shader_parameter/flash_amount", 1.0, 0.2)
	
	flash_tween.chain()
	
	for y in range(3):
		for x in range(3):
			flash_tween.tween_property(grid[y][x].material, "shader_parameter/flash_amount", 0.0, 0.2).set_trans(Tween.TRANS_CUBIC)
