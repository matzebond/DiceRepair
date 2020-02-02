extends Node2D
const Die = preload("res://scenes/die/Die.tscn")
const DiePreview = preload("res://scenes/die/DiePreview.tscn")

const ROUND_TIME = 20
const DICE_MIN_DST = 120


func end_scene():
    pass


func start_scene(dice):
    get_tree().current_scene.game_running = true
    get_tree().current_scene.time = ROUND_TIME
    var dice_inst = []
    for die in dice:
        var die_inst = Die.instance().init(die)
        self.add_die(die_inst)
        dice_inst.append(die_inst)
        
    yield(get_tree().create_timer(3.0), "timeout")
    
    var previews = {}

    for die in dice_inst:
        var preview = DiePreview.instance()
        die.add_child(preview)
        preview.init(die)
        preview.global_position = die.global_position + Vector2(50, 0)
        previews[die.name] = preview
        yield(get_tree().create_timer(0.2), "timeout")
    
    yield(get_tree().create_timer(5.0), "timeout")
    
    for die in dice_inst:
        previews[die.name].destroy()
        previews.erase(die.name)
        yield(get_tree().create_timer(0.1), "timeout")
    
    get_tree().current_scene.end_scene()

        
func add_die(die):
    var area = Rect2($DieArea.global_position, $DieArea.scale * 2 * Vector2(100,100))
    area.position -= area.size / 2
    die.position = random_die_pos(area)
    if die.get_parent() == null:
        self.add_child(die)
    die.roll()
    
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
