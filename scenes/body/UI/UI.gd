extends Control

@onready var mainROM = $"../../mainROM"
@onready var effects = $"../../effects"

@onready var bet_medals = $"bet_medals"
@onready var medal_pay = $"medal_pay/status"
@onready var medal_sum = $"medal_sum/status"
@onready var game_count = $"game_count/status"
@onready var total_count = $"total_count/status"

var total_medal: int:
	set(value):
		if total_medal == value:
			return
		update_total_medal(total_medal, value)
		total_medal = value



var pay_tween: Tween
var sum_tween: Tween

signal bet(value : int)
signal bonus(value)
signal spin()
signal prized()
signal bonus_prized(value : String)

func _ready():
	if mainROM:
		if mainROM.has_signal("medal_bet"):
			mainROM.medal_bet.connect(_on_medal_bet)
		if mainROM.has_signal("medal_number"):
			mainROM.medal_number.connect(_on_medal_number)
		if mainROM.has_signal("bonus_est"):
			mainROM.bonus_est.connect(_on_bonus_est)
		if mainROM.has_signal("spin_start"):
			mainROM.spin_start.connect(_on_spin_start)
		if mainROM.has_signal("prized_role"):
			mainROM.prized_role.connect(_on_prized)
		if mainROM.has_signal("bonus_prized"):
			mainROM.bonus_prized.connect(_on_bonus_prized)
	if effects:
		if effects.has_signal("game_count_update"):
			effects.game_count_update.connect(_on_game_count_update)
		if effects.has_signal("total_count_update"):
			effects.total_count_update.connect(_on_total_count_update)
	if bet_medals and bet_medals.has_method("_on_bet"):
		bet.connect(Callable(bet_medals, "_on_bet"))

	initialize_data()

func initialize_data() -> void:
	game_count.text = str(effects.game_count)
	total_count.text = str(effects.total_count)
	medal_sum.text = str(mainROM.medal_sum)
	medal_pay.text = str(0)



func _on_medal_bet(value):
	medal_pay.text = str(0)
	bet.emit(value)

func _on_medal_number(value):
	total_medal = value

func update_total_medal(start, goal):
	sum_tween = count_up(medal_sum, sum_tween, start, goal)

func _on_game_count_update(game):
	game_count.text = str(game)

func _on_total_count_update(game):
	total_count.text = str(game)

func _on_bonus_est(value):
	bonus.emit(value)

func _on_spin_start():
	spin.emit()

func _on_prized(value):
	if not value:
		return
	var payout = value["payout"]
	pay_tween = count_up(medal_pay, pay_tween, 0, payout)

	
func _on_bonus_prized(value):
	bonus_prized.emit(value)


func count_up(target: Label, tween: Tween, start: int, goal: int) -> Tween:
	if tween:
		tween.kill()
	
	if goal <= start:
		target.text = str(goal)
		return null
	tween = create_tween()
	tween.tween_method(func(val: int): target.text = str(val), start, goal, 0.3)

	return tween

