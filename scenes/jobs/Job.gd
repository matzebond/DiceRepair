extends Node2D
const JobStepScene = preload("JobStep.tscn")

signal completed

const PADDING = Vector2(0, -8)
const JOB_STEP_SIZE = Vector2(0, 164)

export var color:Color = Color(1, 1, 1)

var money_reward = 5

var steps_min:int = 2
var steps_max:int = 3
var steps:int
var current_step = 0

onready var root = get_tree().current_scene


func _ready():
    steps_min = 2 + floor(root.game_round / 2.0)
    steps_max = 2 + ceil(root.game_round / 2.0)
    update_tool()

func update_tool():
    $Sprite.modulate = color
    
    # remove all JobSteps
    for child in $Steps.get_children():
        $Steps.remove_child(child)
    
    # add JobSteps
    steps = rand_range(steps_min, steps_max+1)
    var cur_pos = Vector2(2,0)
    for i in range(steps):
        var jobStep = JobStepScene.instance()
        var work = root.rng.randi_range(max(1, 4-root.game_round), 12+root.game_round)
        jobStep.init(cur_pos, color, work)
        jobStep.connect("done", self, "_on_JobStep_done")
        $Steps.add_child(jobStep)

        # calc next pos
        cur_pos -= JOB_STEP_SIZE
        cur_pos -= PADDING
        
    $Sprite.position = cur_pos
    position.y -= JOB_STEP_SIZE.y/2
    current_step = 0
    enable_step(0)
    
    
func _on_JobStep_done(jobstep):
    current_step += 1
    if current_step >= steps:
        get_tree().current_scene.add_money(money_reward, position)
    
    $Tween.interpolate_property(self, "position:y", position.y, position.y+JOB_STEP_SIZE.y+PADDING.y, 0.6, Tween.TRANS_EXPO, Tween.EASE_IN, 0.6)
    $Tween.start()
    
    if $Steps.get_child_count() > 0:
        $Steps.get_child(0).enable(true)
    else:
        emit_signal("completed")
        
func can_finish_step(dice):
    if $Steps.get_child_count() > 0:
        return $Steps.get_child(0).can_finish(dice)
    else:
        return true
    
func enable_step(id):
    for i in range($Steps.get_child_count()):
        $Steps.get_child(i).enable((id) == i)
