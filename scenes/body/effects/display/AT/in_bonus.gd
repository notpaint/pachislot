extends Control

@onready var GAME = $"playing/GAME"
@onready var GET = $"playing/GET"
@onready var TOTAL = $"playing/TOTAL"

var bonus_game: int = 0
var display_game: int = 0

var bonus_tween: Tween


func start_bonus(game: int) -> void:
	bonus_game = game
	display_game = 40
	GAME.visible = true
	GET.visible = true

	GAME.get_node("status").text = "%dG" % display_game
	GET.get_node("status").text = str(0)


func update_bonus_game(game: int) -> void:
	bonus_game -= game
	display_game -= 1

	GAME.get_node("status").text = "%dG" % display_game

func update_bonus_get(bonus_get_target, bonus_get) -> void:
	if bonus_tween:
		bonus_tween.kill()
	if bonus_get_target <= bonus_get:
		bonus_get = bonus_get_target
		return
	bonus_tween = create_tween()
	bonus_tween.tween_property(self, "bonus_get", bonus_get_target, 0.3)