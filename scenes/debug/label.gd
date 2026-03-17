extends Label

func _process(delta: float):
    text = str(Engine.get_frames_per_second())