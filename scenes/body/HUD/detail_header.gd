extends PanelContainer

@onready var est_status = $"detail/est/status"
@onready var now_status = $"detail/now/status"
@onready var rt_name = $"detail/rt/status/name"
@onready var rt_count = $"detail/rt/status/count"

var HUD_data : Dictionary

func _ready() -> void:
	HUD_data = main.HUD_data
	est_status.text = "ー"
	now_status.text = "ー"
	rt_name.text = "RT0"
	rt_count.text = "%4s" % "ー"

func _on_bonus_est(bonus):
	if HUD_data.has(bonus):
		var display_name = HUD_data[bonus]
		est_status.text = display_name
	else:
		est_status.text = bonus if bonus else "ー"

func _on_bonus_prized(bonus):
	if HUD_data.has(bonus):
		var display_name = HUD_data[bonus]
		now_status.text = display_name
	else:
		if bonus == "None":
			now_status.text = "ー"
		else:
			now_status.text = bonus if bonus else "ー"

func _on_now_RT(RT):
	if RT == "None" or RT == "":
		rt_name.text = "%3s" % "RT0"
	else:
		rt_name.text = "%3s" % RT

func _on_last_RT(game):
	if game == 0:
		rt_count.text = "%4d" % 0
	elif game < 0:
		rt_count.text = "%4s" % "ー"
	else:
		rt_count.text = "%4d" % game
