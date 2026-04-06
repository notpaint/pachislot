extends Control

@onready var mainROM = $"../../mainROM"
@onready var force_flag = $"force_flag"
@onready var flaglist = $"force_flag/flaglist"


var current_bet : int = 0
var current_RT : String = "RT0"
var current_bonus : String = "None"

var weight_table = {}
var current_weight_table = {}


signal load_weight(value: Dictionary)

func _ready():
	weight_table = Database.weight_table
	connect_signal()


func connect_signal():
	if mainROM:
		mainROM.medal_bet.connect(change_medals)
		mainROM.now_RT.connect(change_RT)
		mainROM.now_bonus.connect(change_bonus)
		mainROM.spin_start.connect(clear_weight)
	if flaglist:
		load_weight.connect(Callable(flaglist, "_on_load_weight"))
		var pop = flaglist.get_popup()
		pop.window_input.connect(_on_popup_input)


func _unhandled_input(event):
	if event.is_action_pressed("maxbet"):
		Datahub.request_maxbet()
	if event.is_action_pressed("lever"):
		Datahub.request_lever()
	if event.is_action_pressed("stop_left"):
		if not Datahub.result_flag == "None":
			Datahub.request_stop(0)
	if event.is_action_pressed("stop_center"):
		if not Datahub.result_flag == "None":
			Datahub.request_stop(1)
	if event.is_action_pressed("stop_right"):
		if not Datahub.result_flag == "None":
			Datahub.request_stop(2)
	if Input.is_action_just_pressed("debug_popup"):
		var flag_pop = flaglist.get_popup()
		if flag_pop.get_item_count() == 0:
			return
		if not flag_pop.visible:
			flaglist.show_popup()
			var index = flaglist.selected if flaglist.selected >= 0 else 0
			flag_pop.set_focused_item(index)
	if Input.is_action_just_pressed("debug_send"):
		var flag_pop = flaglist.get_popup()
		if not flag_pop.visible:
			var index = flaglist.selected
			if index >= 0:
				force_flag._on_send_pressed()


func _on_popup_input(event):
	if event.is_action_pressed("debug_popup"):
		var flag_pop = flaglist.get_popup()
		if flag_pop.visible:
			var index = flag_pop.get_focused_item()
			if index >= 0:
				var id = flag_pop.get_item_id(index)
				flag_pop.id_pressed.emit(id)
				flaglist.selected = index
				flag_pop.hide()
	if event.is_action_pressed("debug_send"):
		var flag_pop = flaglist.get_popup()
		if flag_pop.visible:
			var index = flag_pop.get_focused_item()
			if index >= 0:
				var id = flag_pop.get_item_id(index)
				flag_pop.id_pressed.emit(id)
				flaglist.selected = index
				force_flag._on_send_pressed()
				flag_pop.hide()



func change_medals(medals):
	current_bet = medals
	_load_weight_table()

func change_RT(RT):
	current_RT = RT
	_load_weight_table()

func change_bonus(bonus):
	current_bonus = bonus
	_load_weight_table()

func _load_weight_table():
	if not weight_table.has(current_bonus):
		return null
	if not weight_table[current_bonus].has(current_RT):
		return null
	if not weight_table[current_bonus][current_RT].has(current_bet):
		return null

	current_weight_table = weight_table[current_bonus][current_RT][current_bet]

	load_weight.emit(current_weight_table)


func clear_weight():

	load_weight.emit([])
