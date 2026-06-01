extends Node2D

@onready var mainROM = $"../../mainROM"

@onready var parrot = $"parrot"
@onready var reverse_parrot = $"reverse_parrot"

func _ready():
    if mainROM:
        if mainROM.has_signal("bonus_est"):
            mainROM.bonus_est.connect(_on_bonus_est)
        if mainROM.has_signal("bonus_prized"):
            mainROM.bonus_prized.connect(_on_bonus_prized)
        if mainROM.has_signal("spin_start"):
            mainROM.spin_start.connect(_on_spin_start)
        if mainROM.has_signal("prized"):
            mainROM.prized.connect(_on_prized)

func _on_bonus_est(value):
    parrot._on_bonus_est(value)
    reverse_parrot._on_bonus_est(value)

func _on_bonus_prized(value):
    parrot._on_bonus_prized(value)
    reverse_parrot._on_bonus_prized(value)

func _on_spin_start():
    parrot._on_spin()
    reverse_parrot._on_spin()

func _on_prized(value):
    parrot._on_prized()
    reverse_parrot._on_prized()
