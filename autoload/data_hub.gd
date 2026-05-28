extends Node

var result_flag :
    set(value):
        if result_flag == value:
            return
        result_flag = value
        _result_flag.emit(value)

var force_flag : String = "None"

var bonus_state
var current_RT : String = "RT0"
var current_bonus : String = "None"
var current_JAC : String = "None"
var bet_medals : int = 0

signal _result_flag(flag)
signal maxbet_requested()
signal lever_requested()
signal stop_requested(reel_pos)
signal debug_requested()

func request_maxbet():
    maxbet_requested.emit()

func request_lever():
    lever_requested.emit()

func request_stop(reel_pos : int):
    stop_requested.emit(reel_pos)

func request_debug():
    debug_requested.emit()

