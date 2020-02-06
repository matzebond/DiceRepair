extends Node2D
const JobStepScene = preload("JobStep.tscn")

signal completed

const PADDING = Vector2(0, -8)
const JOB_STEP_SIZE = Vector2(0, 164)

var money_reward = 5

var steps_min:int = 2
var steps_max:int = 3
var steps:int

var next_job_pos
var step_scenes = []

var current_step = 0

onready var root = get_tree().current_scene


func _ready():
    steps_min = 2 + floor(root.game_round / 2.0)
    steps_max = 2 + ceil(root.game_round / 2.0)
    next_job_pos = $Steps.global_position
    add_jobs()
    

func add_jobs():
    steps = rand_range(steps_min, steps_max+1)
    var cur_pos = Vector2(2,0)
    
    for i in range(steps):
        step_scenes.push_back(null)
        
    for i in range(steps):
        var jobStep = JobStepScene.instance()
        var work = root.rng.randi_range(max(1, 4-root.game_round), 12+root.game_round)

        $Steps.add_child_below_node($Steps/FirstElem, jobStep)
        $Steps.position.y -= JOB_STEP_SIZE.y + PADDING.y
        
        jobStep.init(cur_pos, work)
        jobStep.connect("done", self, "_on_JobStep_done")
        jobStep.global_position = next_job_pos
        step_scenes[steps-1-i] = jobStep
    
    current_step = 0
    enable_step(current_step)
    
    
func _on_JobStep_done(jobstep):

    $Tween.interpolate_property($Steps, "position:y", $Steps.position.y, $Steps.position.y+JOB_STEP_SIZE.y+PADDING.y, 0.6, Tween.TRANS_EXPO, Tween.EASE_IN, 0.6)
    $Tween.start()
    
    current_step += 1
    if current_step >= steps:
        get_tree().current_scene.add_money(money_reward, position)
        done()
    else:
        enable_step(current_step)
    
func done():
    emit_signal("completed")
    $Tween.interpolate_property($Steps/JobHead/Inactive, "color:a", $Steps/JobHead/Inactive.color.a, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.start()
        
func can_finish_step(dice):
    if $Steps.get_child_count() > 0:
        return step_scenes[current_step].can_finish(dice)
    else:
        return true
    
func enable_step(id):
    for i in range(current_step, len(step_scenes)):
        step_scenes[i].enable((id) == i)
