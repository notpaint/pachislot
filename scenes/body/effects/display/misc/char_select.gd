extends Control

var characters:Array = []
var center_positions: Array[Vector2] = []
var index: int = 0

var layout_tween: Tween

signal character(char)

func _ready() -> void:
    for child in get_children():
        characters.append(child)
        var center_pos = child.position + (child.size / 2.0)
        center_positions.append(center_pos)

func _notification(what) -> void:
    if what == NOTIFICATION_VISIBILITY_CHANGED:
        if visible and not characters.is_empty():
            index = 0
            character.emit(characters[0].name)
            initialize_layout()

func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return

    if not event.is_pressed() or event.is_echo():
        return
    
    if event.is_action_pressed("menu_right"):
        select_char(1)

    if event.is_action_pressed("menu_left"):
        select_char(-1)

func select_char(vector: int) -> void:
    index = (index + 3 + vector) % 3
    var char_name = characters[index].name
    character.emit(char_name)
    update_layout()

func initialize_layout() -> void:
    for i in range(characters.size()):
        characters[i].position = get_position_index(i) - (characters[i].size/ 2.0)

func update_layout() -> void:
    if layout_tween:
        layout_tween.kill()
    
    layout_tween = create_tween().set_parallel(true)

    for i in range(characters.size()):
        var target_center = get_position_index(i)

        var target_pos = target_center - (characters[i].size / 2.0)

        layout_tween.tween_property(characters[i], "position", target_pos, 0.3)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func get_position_index(char_idx: int) -> Vector2:
    var diff = (char_idx + 3 - index) % 3
    return center_positions[diff]