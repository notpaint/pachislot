extends Control

@onready var mainROM = $"../../mainROM"
@onready var flaglist = $"force_flag/flaglist"

var current_bet : int = 0
var current_RT : String = "RT0"
var current_bonus : String = "None"

var weight_table = {}
var current_weight_table = {}

signal load_weight(value: Dictionary)

func _ready():
    weight_table = Database.weight_table
    if mainROM:
        mainROM.medal_bet.connect(change_medals)
        mainROM.now_RT.connect(change_RT)
        mainROM.now_bonus.connect(change_bonus)
        mainROM.spin_start.connect(clear_weight)
    if flaglist:
        load_weight.connect(Callable(flaglist, "_on_load_weight"))

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