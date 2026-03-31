extends OptionButton

var current_weight_table : Array = []
var current_list : Array = []


func _ready():
	pass

func _on_load_weight(weight):
	current_weight_table = weight
	_rebuild(current_weight_table)


func _rebuild(table):
	clear()
	current_list.clear()
	for row in table:
		var flag = row["flag"]
		if not flag in current_list:
			current_list.append(flag)
	for flag in current_list:
		add_item("%s" %flag)
		var id = item_count - 1
		set_item_metadata(id, flag)
