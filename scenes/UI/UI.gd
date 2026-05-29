extends Control

@onready var mainROM = $"../../mainROM"

@onready var bet_medals = $"bet_medals"
@onready var parrot = $"parrot"
@onready var medal_sum = $"medal_sum"

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
        if mainROM.has_signal("prized"):
            mainROM.prized.connect(_on_prized)
        if mainROM.has_signal("bonus_prized"):
            mainROM.bonus_prized.connect(_on_bonus_prized)
    if bet_medals and bet_medals.has_method("_on_bet"):
        bet.connect(Callable(bet_medals, "_on_bet"))
    if parrot:
        if parrot.has_method("_on_bonus"):
            bonus.connect(Callable(parrot, "_on_bonus"))
        if parrot.has_method("_on_spin"):
            spin.connect(Callable(parrot, "_on_spin"))
        if parrot.has_method("_on_prized"):
            prized.connect(Callable(parrot, "_on_prized"))
        if parrot.has_method("_on_bonus_prized"):
            bonus_prized.connect(Callable(parrot, "_on_bonus_prized"))


func _on_medal_bet(value):
    bet.emit(value)

func _on_medal_number(value):
    medal_sum.text = str(value)

func _on_bonus_est(value):
    bonus.emit(value)

func _on_spin_start():
    spin.emit()

func _on_prized():
    prized.emit()

func _on_bonus_prized(value):
    bonus_prized.emit(value)