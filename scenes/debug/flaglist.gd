extends OptionButton

var test_table : Dictionary = {
    "middleBell" : 1000,
    "BB1" : 3154,
    "vac" : 3000
}

var selected_flag = ""

func _ready():
    _rebuild(test_table)

func _rebuild(table):

    var keys : Array = table.keys()

    keys.sort()

    for key in keys:
        var weight : int = int(table[key])
        var index = item_count
        add_item("%s : %d" %[key, weight])
        set_item_metadata(index, key)
