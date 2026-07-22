extends PanelContainer

@onready var roles = $"spacer/result_roles/roles"

var HUD_data: Dictionary

func _ready() -> void:
	HUD_data = main.HUD_data
	for child in roles.get_children():
		child.queue_free()

func _on_roles(value):
	for child in roles.get_children():
		child.queue_free()
	for i in value.size():
		var role_name = value[i]["role"]
		var display_name = role_name
		if HUD_data.has(role_name):
			display_name = HUD_data[role_name]
		var label := Label.new()
		label.text = display_name
		roles.add_child(label)
