extends PopupDialog

const CENTER_OFFSET = Vector2(0, -38)
var current_target_pos

func show_text(text, position):
    current_target_pos = position
    
    $Tween.stop_all()
    modulate.a = 1
    
    $CenterContainer/Label.text = text
    _on_Label_draw()
    
    $Tween.interpolate_property(self, "modulate:a", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 2)
    $Tween.start()
    popup()
    
func hide():
    visible = false
    current_target_pos = null

func _on_Label_draw():
    if current_target_pos:
        rect_min_size = $CenterContainer/Label.rect_size + Vector2(10, 10)
        rect_size = rect_min_size
        rect_global_position = current_target_pos + CENTER_OFFSET -rect_min_size/2.0
        
