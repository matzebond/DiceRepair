extends Node2D
const Die = preload("res://scenes/die/Die.tscn")

const DICE_MIN_DST = 120
const NUM_JOBS = 3
const ROUND_DONE_WAIT = 1.5

var cur_num_jobs = NUM_JOBS

var ready = false

func _ready():
    for job in get_tree().get_nodes_in_group("Job"):
        job.connect("completed", self, "_on_Job_completed")
    
    $DieAreaPanel.set('custom_styles/panel', $DieAreaPanel.theme.get_stylebox("DottedPanel", "Panel"))

func end_scene():
    get_tree().current_scene.game_running = false
    get_tree().current_scene.game_round += 1

func start_scene(dice):
    get_tree().current_scene.game_running = true
    $Round.text = "%02d" % [get_tree().current_scene.game_round+1]
    for die in dice:
        var die_inst = Die.instance().init(die)
        self.add_die([die_inst])
    ready = true
    finish_possible()


func add_die(dice):
    if not dice is Array:
        dice = [dice]
    for die in dice:
        if die.get_parent() == null:
            self.add_child(die)
        die.roll($DieArea.get_area())
    
    if ready:
        finish_possible()
    
func finish_possible():
    if not is_finish_possible():
        print("impossible")
        yield(get_tree().create_timer(10.0), "timeout") # hacky AF
        if not is_finish_possible():
            get_tree().current_scene.restart()
        else:
            print("now possible")

func is_finish_possible():
    if get_tree().current_scene.can_pay_reroll():
        return true
    var has_unfinishable_job = false
    for job in get_tree().get_nodes_in_group("Job"):
        if not job.is_done():
            if job.can_finish_step(get_tree().current_scene.dice):
                return true
            else:
                has_unfinishable_job = true
    return not has_unfinishable_job
    

func _on_Job_completed():
    cur_num_jobs -= 1
    if cur_num_jobs <= 0:
        yield(get_tree().create_timer(ROUND_DONE_WAIT), "timeout")
        get_tree().current_scene.end_scene()

func get_next_scene():
    return "Upgrade"

func _on_RerollArea_drop_item(item):
    if not item.try_roll($DieArea.get_area()):
        item.snap_back()
