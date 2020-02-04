extends Node2D
const Die = preload("res://scenes/die/Die.tscn")
const DieScript = preload("res://scenes/die/Die.gd")
const DiePreview = preload("res://scenes/die/DiePreview.tscn")

const DICE_MIN_DST = 260

func end_scene():
    pass


func start_scene(dice):
    var dice_inst = []
    for die in dice:
        var die_inst = Die.instance().init(die)
        self.add_die(die_inst)
        dice_inst.append(die_inst)
        yield(get_tree().create_timer(1), "timeout")
        
    yield(get_tree().create_timer(3.0), "timeout")
    
    var previews = {}

    for die in dice_inst:
        var preview = DiePreview.instance()
        die.state = DieScript.Blocked
        die.add_child(preview)
        preview.init(die)
        previews[die.name] = preview
        yield(get_tree().create_timer(0.2), "timeout")
    
    yield(get_tree().create_timer(5.0), "timeout")
    
    for die in dice_inst:
        previews[die.name].destroy()
        previews.erase(die.name)
        die.state = DieScript.Default
        yield(get_tree().create_timer(0.1), "timeout")
    
    yield(get_tree().create_timer(2.0), "timeout")
    
    get_tree().current_scene.end_scene()
    
func _input(event):
    if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
        get_tree().current_scene.end_scene()

        
func add_die(die):
    var area = Rect2($DieArea.global_position, $DieArea.scale * 2 * Vector2(100,100))
    area.position -= area.size / 2
    die.position = random_die_pos(area)
    yield(get_tree(), "idle_frame")
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
