extends Node2D
const Die = preload("res://scenes/die/Die.tscn")

const DICE_MIN_DST = 250

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
    var zone = $ToolBench/DropArea
    var area = Rect2(zone.global_position, zone.scale * 2 * Vector2(100,100))
    area.position -= area.size / 2
    die.position = random_die_pos(area)
    self.add_child(die)
    
    $ToolBench._on_DropArea_drop_item(die) # instantly open preview


func random_die_pos(area):
    var iter = 0
    var pos
    while iter < 1000:
        var x = area.position.x + rand_range(0, area.size.x)
        var y = area.position.y + rand_range(0, area.size.y)
        pos = Vector2(x,y)
        var pos_ok = true

        for die in get_tree().get_nodes_in_group("die"):
            if die.position.distance_to(pos) < DICE_MIN_DST:
                pos_ok = false
        if pos_ok:
            return pos
        iter += 1
    return pos


func get_next_scene():
    return "Game"
