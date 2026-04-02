extends Control

@onready var maxbet = $"maxbet"
@onready var lever = $"lever"

func _ready():
    maxbet.pressed.connect(_on_maxbet)
    lever.pressed.connect(_on_lever)

func _on_maxbet():
    Datahub.request_maxbet()

func _on_lever():
    Datahub.request_lever()