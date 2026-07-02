extends Node2D

@onready var effects = $"../.."

@onready var parrot = $"parrot"
@onready var reverseparrot = $"reverseparrot"

func _on_bonus_est(value):
	if effects.bonus_state:
		parrot.play("parrot")
		reverseparrot.play("reverseparrot")

func _on_bonus_prized(value):
	if parrot.has_method("_on_bonus_prized"):
		parrot._on_bonus_prized(value)

func _on_spin_start():
	if effects.bonus_est:
		parrot.play("parrot")
		reverseparrot.play("reverseparrot")

func _on_prized(value):
	if parrot.has_method("_on_prized"):
		parrot._on_prized()
