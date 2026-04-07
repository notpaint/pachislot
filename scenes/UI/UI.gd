extends Control

@onready var mainROM = $"../../mainROM"

@onready var bet_medals = $"bet_medals"
@onready var medal_sum = $"medal_sum"

signal bet(value : int)

func _ready():
    if mainROM:
        if mainROM.has_signal("medal_bet"):
            mainROM.medal_bet.connect(_on_medal_bet)
        if mainROM.has_signal("medal_number"):
            mainROM.medal_number.connect(_on_medal_number)
    if bet_medals and bet_medals.has_method("_on_bet"):
        bet.connect(Callable(bet_medals, "_on_bet"))
            
func _on_medal_bet(value):
    bet.emit(value)

func _on_medal_number(value):
    medal_sum.text = str(value)