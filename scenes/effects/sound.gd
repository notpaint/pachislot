extends Node

@onready var mainROM = $"../../mainROM"

@onready var music = $"music"

signal start_bonus(value : String)

func _ready():
    if mainROM and mainROM.has_signal("now_bonus"):
        mainROM.now_bonus.connect(_on_now_bonus)
    if music and music.has_method("start_music"):
        start_bonus.connect(Callable(music, "start_music"))

func _on_now_bonus(value):
    start_bonus.emit(value)