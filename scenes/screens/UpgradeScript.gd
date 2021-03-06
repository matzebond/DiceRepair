extends Node2D
const Die = preload("res://scenes/die/Die.tscn")

signal money_changed(money)

func _on_StartButton_pressed():
    get_tree().current_scene.end_scene()
    
func start_scene(dice):
    for die in dice:
        var die_inst = Die.instance().init(die)
        self.add_die(die_inst)
        
func end_scene():
    pass
        
func add_die(die):
    var area = $ToolBench/DropArea.get_area()
    
    # following lines important, since roll() not called
    die.last_roll_area = area
    die.position = get_tree().current_scene.random_die_pos(area, 200)
    die.last_roll_target_pos = die.position
    
    self.add_child(die)
    
    $ToolBench._on_DropArea_drop_item(die) # instantly open preview

func get_next_scene():
    return "Game"
