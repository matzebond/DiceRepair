extends Node2D


func _on_StartButton_pressed():
    get_tree().current_scene.end_scene()
    
func start_scene():
    pass    
    
func end_scene():
    pass

func get_next_scene():
    return "Game"
