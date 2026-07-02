extends HBoxContainer

const OFF : Color = Color(0.5,0.5,0.5)
const ON : Color = Color(1.0,1.0,1.0)

var children : Array

var time : int = 0

func _ready():
	children = get_children()
	_on_bet(0)


func _on_bet(value):
 
	for child in children:
		child.modulate = OFF
	
	var n : int = clampi(value, 0, children.size())

	for i in range(n):
		var child = children[i]
		child.modulate = ON
