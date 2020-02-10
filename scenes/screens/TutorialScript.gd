extends Node2D
const Die = preload("res://scenes/die/Die.tscn")
const DieScript = preload("res://scenes/die/Die.gd")
const DiePreview = preload("res://scenes/die/DiePreview.tscn")

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
        die.block()
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
    if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") \
        or (event is InputEventKey and event.scancode == KEY_MENU):
            get_tree().current_scene.end_scene()

        
func add_die(die):
    var area = Rect2($DieArea.global_position, $DieArea.scale * 2 * Vector2(100,100))
    area.position -= area.size / 2
    yield(get_tree(), "idle_frame")
    if die.get_parent() == null:
        self.add_child(die)        
    die.roll(area)
    

    
func get_next_scene():
    return "Game"
