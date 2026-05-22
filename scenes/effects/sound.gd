extends Node
@onready var mainROM = $"../../mainROM"
@onready var music = $"music"

signal bonus_prized(value : String)
signal medal_bet(value : int)

func _ready():
    if mainROM and mainROM.has_signal("bonus_prized"):
        mainROM.bonus_prized.connect(_on_bonus_prized)
    if mainROM and mainROM.has_signal("medal_bet"):
        mainROM.medal_bet.connect(_on_medal_bet)
    if music and music.has_method("bonus_prized"):
        bonus_prized.connect(Callable(music, "bonus_prized"))
    if music and music.has_method("medal_bet"):
        medal_bet.connect(Callable(music, "medal_bet"))

func _on_bonus_prized(value):
    bonus_prized.emit(value)

func _on_medal_bet(value):
    medal_bet.emit(value)

func _on_start_bonus(value):
    pass