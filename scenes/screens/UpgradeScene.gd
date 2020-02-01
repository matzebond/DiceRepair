extends Node2D

const Die = preload("res://scenes/die/Die.tscn")

func _on_StartButton_pressed():
    get_tree().current_scene.end_scene()
    
func start_scene(dice):
    for die in dice:
        var die_inst = Die.instance().init(die[0], die[1], die[2])
        self.add_die(die_inst)
        
        
func add_die(die):
    self.add_child(die)
    print(die.state)

    
func end_scene():
    pass

func get_next_scene():
    return "Game"
