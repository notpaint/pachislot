extends Node2D

@onready var order_navi = $"../../order_navi"

func _on_stop_button(reel_pos):
	order_navi.push_navi(reel_pos)