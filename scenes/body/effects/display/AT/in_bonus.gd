extends Control

@onready var playing = $"playing"
@onready var result = $"result"

@onready var containers: Dictionary = {
	"GAME": $"playing/GAME",
	"GET": $"playing/GET",
	"TOTAL": $"playing/TOTAL"
}

@onready var status_label: Dictionary = {
	"GAME": $"playing/GAME/status",
	"GET": $"playing/GET/status",
	"TOTAL": $"playing/TOTAL/status"
}

var bonus_game: int = 0
var display_game: int = 0

var bonus_get_current: int = 0
var total_get_current: int = 0

var bonus_tween: Tween


func start_bonus(game: int) -> void:
	bonus_game = game
	display_game = 40
	containers["GAME"].visible = true
	containers["GET"].visible = true
	status_label["GAME"].text = "%d" % display_game
	status_label["GET"].text = "0"

func _on_flaged(_value):
	# print("this is in_bonus", value)
	bonus_game -= 1
	display_game -= 1

	status_label["GAME"].text = "%d" % display_game

func update_bonus_get(bonus_get) -> void:
	if bonus_tween:
		bonus_tween.kill()
	if bonus_get <= bonus_get_current:
		bonus_get_current = bonus_get
		status_label["GET"].text = str(bonus_get)
		return
	bonus_tween = create_tween()
	bonus_tween.tween_method(
		func(val: int):
			bonus_get_current = val
			status_label["GET"].text = str(val),
		bonus_get_current,
		bonus_get,
		0.3
		)

func bonus_end() -> void:
	pass
