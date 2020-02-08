extends Node2D
const JobStepScene = preload("JobStep.tscn")
const JobRewardScene = preload("JobReward.tscn")

signal completed

const PADDING = Vector2(0, -8)
const JOB_STEP_SIZE = Vector2(0, 164)
const UpgradeButton = preload("res://scenes/ugrades/UpgradeButton.gd")
const Die = preload("res://scenes/die/Die.gd")

var upgrade_pool = [UpgradeButton.PlusDeltaUpgrade.new(2), UpgradeButton.PlusDeltaUpgrade.new(5), UpgradeButton.SetNumberUpgrade.new(10),
    UpgradeButton.MinusDeltaUpgrade.new(2), UpgradeButton.MinusDeltaUpgrade.new(5), UpgradeButton.SetNumberUpgrade.new(1), 
    UpgradeButton.SetToolUpgrade.new(Die.Hammer), UpgradeButton.SetToolUpgrade.new(Die.Drill), UpgradeButton.SetToolUpgrade.new(Die.Ratchet),
    UpgradeButton.SetToolUpgrade.new(Die.Saw)
]

var steps_min:int = 2
var steps_max:int = 3
var steps:int

var next_job_pos
var job_elems = []

var current_step = 0

onready var root = get_tree().current_scene

export var initial_anim_delay = 0.0

func _ready():
    steps_min = 2 + floor(root.game_round / 2.0)
    steps_max = 2 + ceil(root.game_round / 2.0)
    steps = rand_range(steps_min, steps_max+1)
    
    next_job_pos = $Steps.global_position
    add_reward()
    
    add_jobs()
    current_step = 0
    
    # Start animation
    var start_y = $Steps.position.y - 600 - JOB_STEP_SIZE.y*steps
    var end_y = $Steps.position.y
    $Steps.position.y = start_y
    $Tween.connect("tween_completed", self, "initial_anim_done", [], CONNECT_ONESHOT)
    $Tween.interpolate_property($Steps, "position:y", start_y, end_y, 1.2, Tween.TRANS_EXPO, Tween.EASE_IN, initial_anim_delay)
    $Tween.start()

func initial_anim_done(_obj, _key):
    enable_step(current_step)

func add_jobs():
    for i in range(steps):
        var jobStep = JobStepScene.instance()
        var work = root.rng.randi_range(max(1, 4-root.game_round), 12+root.game_round)
        jobStep.init(cur_pos, work)
        add_job_elem(jobStep)

func add_reward():
    var jobStep = JobRewardScene.instance()
    jobStep.init(cur_pos, upgrade_pool[randi() % len(upgrade_pool)])
    add_job_elem(jobStep)

var cur_pos = Vector2(2,0)
func add_job_elem(elem):
    $Steps.position.y -= JOB_STEP_SIZE.y + PADDING.y

    $Steps.add_child_below_node($Steps/FirstElem, elem)
    job_elems.push_front(elem)
    
    elem.connect("done", self, "_on_JobStep_done")
    elem.global_position = next_job_pos
    
func _on_JobStep_done(jobstep):
    $Tween.connect("tween_completed", self, "after_JobStep_anim_done", [], CONNECT_ONESHOT)
    $Tween.interpolate_property($Steps, "position:y", $Steps.position.y, $Steps.position.y+JOB_STEP_SIZE.y+PADDING.y, 0.6, Tween.TRANS_EXPO, Tween.EASE_IN, 0.6)
    $Tween.start()

func after_JobStep_anim_done(_obj, _key):
    current_step += 1
    if current_step >= len(job_elems):
        done()
    else:
        enable_step(current_step)
    
func done():
    emit_signal("completed")
    $Tween.start()
    
func is_done():
    return current_step >= len(job_elems)
        
func can_finish_step(dice):
    if current_step < len(job_elems):
        return job_elems[current_step].can_finish(dice)
    else:
        return false
    
func enable_step(id):
    for i in range(current_step, len(job_elems)):
        job_elems[i].enable((id) == i)
