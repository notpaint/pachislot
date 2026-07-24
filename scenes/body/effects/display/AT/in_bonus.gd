extends Control

@onready var playing = $"playing"
@onready var result = $"result"

@onready var containers: Dictionary = {
	"GAME": $"playing/GAME",
	"GET": $"playing/GET",
	"TOTAL": $"playing/TOTAL",
}

@onready var status_label: Dictionary = {
	"GAME": $"playing/GAME/status",
	"GET": $"playing/GET/status",
	"TOTAL": $"playing/TOTAL/status",
	"result": $"result/status",
}

var bonus_game: int = 0
var display_game: int = 0

var bonus_get_current: int = 0
var total_get_current: int = 0

var bonus_tween: Tween

var bonus_updating: bool = false:
	set(value):
		if bonus_updating == value:
			return
		bonus_updating = value
		bonus_updated.emit()

signal bonus_updated

func start_bonus(game: int) -> void:
	playing.visible = true
	result.visible = false
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
	bonus_updating = true
	if bonus_get <= bonus_get_current:
		bonus_get_current = bonus_get
		status_label["GET"].text = str(bonus_get)
		bonus_updating = false
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
	bonus_tween.tween_callback(func():
		bonus_updating = false
	)

func end_bonus(value) -> void:

	status_label["result"].text = str(value)

	playing.visible = false
	result.visible = true
