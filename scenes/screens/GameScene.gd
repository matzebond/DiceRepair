extends Node2D
const Die = preload("res://scenes/die/Die.tscn")

const ROUND_TIME = 20
const DICE_MIN_DST = 120



func end_scene():
    get_tree().current_scene.game_running = false
    get_tree().current_scene.time = 0


func start_scene(dice):
    get_tree().current_scene.game_running = true
    get_tree().current_scene.time = ROUND_TIME
    for die in dice:
        var die_inst = Die.instance().init(die)
        self.add_die(die_inst)
        
        
func add_die(die):
    die.position = random_die_pos()
    if die.get_parent() == null:
        self.add_child(die)
    die.roll()
    
func random_die_pos():
    
    var pos_ok = true
    var iter = 0
    var pos
    while pos_ok and iter < 1000:
        var area = Rect2($DieArea.global_position, $DieArea.scale * Vector2(100,100))
        area.position -= area.size / 2
        var x = area.position.x + rand_range(0, area.size.x)
        var y = area.position.y + rand_range(0, area.size.y)
        pos = Vector2(x,y)
        
        for die in get_tree().get_nodes_in_group("die"):
            if die.position.distance_to(pos) > DICE_MIN_DST:
                pos_ok = false
        iter += 1
    return pos
    
func get_next_scene():
    return "Upgrade"
