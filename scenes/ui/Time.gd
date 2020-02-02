extends Label

func _process(delta):
    
    var scene = get_tree().current_scene
    
    if scene.game_running:
        scene.time = max(0, scene.time - delta)
        if scene.time <= 0:
            get_tree().current_scene.end_scene()
        update_text()


func update_text():
    var scene = get_tree().current_scene
    var time = scene.time
    if time > 1:
        time = ceil(time)
    else:
        time = round(time * 10) / 10
    self.text = str(time)
