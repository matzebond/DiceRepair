extends Node2D
const Die = preload("res://scenes/die/Die.tscn")

const DICE_MIN_DST = 120
const NUM_JOBS = 3

var cur_num_jobs = NUM_JOBS

func _ready():
    for job in get_tree().get_nodes_in_group("Job"):
        job.connect("completed", self, "_on_Job_completed")


func end_scene():
    get_tree().current_scene.game_running = false


func start_scene(dice):
    get_tree().current_scene.game_running = true
    for die in dice:
        var die_inst = Die.instance().init(die)
        self.add_die(die_inst)
        
        
func add_die(die):
    var area = Rect2($DieArea.global_position, 2 * $DieArea.scale * Vector2(100,100))
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
    
func _on_Job_completed():
    cur_num_jobs -= 1
    if cur_num_jobs <= 0:
        get_tree().current_scene.end_scene()

func get_next_scene():
    return "Upgrade"
