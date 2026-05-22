extends AudioStreamPlayer

var RB_start = preload("res://assets/music/A/REG/REG_start.wav")
var RB = preload("res://assets/music/A/REG/REG.wav")

var in_bonus : bool = false
var first_bet : bool = true

func bonus_prized(value):
    if value != "None":
        in_bonus = true
        stream = RB_start
        play()
    else:
        in_bonus = false
        stop()

func medal_bet(value):
    print(value)
    if in_bonus:
        if first_bet:
            first_bet = false
            stream = RB
            play()
