extends Control

@onready var flaglist = $"flaglist"
@onready var send = $"send"

signal force_flag(select_flag)

func _ready():
    send.pressed.connect(_on_send_pressed)

func _on_send_pressed():
    var selected_flag = flaglist.get_item_metadata(flaglist.selected)
    if selected_flag:
        force_flag.emit(selected_flag)
    else:
        print("NULL")
