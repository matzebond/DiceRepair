extends Label

func _process(delta):
    var root = get_tree().current_scene
    if root.game_running:
        root.time -= delta
        if root.time < 0:
            root.stop_round()
        update_text()


func update_text():
    var time = get_tree().current_scene.time
    if time > 1:
        time = ceil(time)
    else:
        time = round(time * 10) / 10
    self.text = "Time: " + str(time)
