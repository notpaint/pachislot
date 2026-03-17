extends Control

@onready var mainROM = $"../../mainROM"

@onready var bet_medals = $"bet_medals"

signal bet(value : int)

func _ready():
    if mainROM and mainROM.has_signal("medal_bet"):
        mainROM.medal_bet.connect(_on_medal_bet)
    if bet_medals and bet_medals.has_method("_on_bet"):
        bet.connect(Callable(bet_medals, "_on_bet"))
            
func _on_medal_bet(value):
    bet.emit(value)