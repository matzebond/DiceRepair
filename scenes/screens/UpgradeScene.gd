extends Node2D
const Die = preload("res://scenes/die/Die.tscn")

signal money_changed(money)

func _on_StartButton_pressed():
    get_tree().current_scene.end_scene()
    
func start_scene(dice, money):
    for die in dice:
        var die_inst = Die.instance().init(die)
        self.add_die(die_inst)
        
        
func add_die(die):
    die.position = random_die_pos()
    self.add_child(die)


func random_die_pos():
    var area = Rect2($DieArea.global_position, $DieArea.scale * Vector2(100,100))
    area.position -= area.size / 2
    var x = area.position.x + rand_range(0, area.size.x)
    var y = area.position.y + rand_range(0, area.size.y)
    return Vector2(x,y)

    
func end_scene():
    pass

func get_next_scene():
    return "Game"
