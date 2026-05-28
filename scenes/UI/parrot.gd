extends AnimatedSprite2D

var spin = false
signal spin_started

func _on_bonus(value):
    if not value:
        return
    self.play("default")
    # if value == "None":
    #     if not is_playing():
    #         frame = 0
    #         return
    #     while frame != 0:
    #         await frame_changed
        
    #     self.stop()
    #     frame = 0
    
func _on_bonus_prized(value):
    if value == "None":
        if not is_playing():
            frame = 0
            return
        while frame != 0:
            await frame_changed
        
        self.stop()
        frame = 0

func _on_spin():
    spin = true
    spin_started.emit()

func _on_prized():
    spin = false