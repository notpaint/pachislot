extends Control


func _on_maxbet():
	Datahub.request_maxbet()

func _on_lever():
	Datahub.request_lever()
