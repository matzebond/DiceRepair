extends Node2D

export var color:Color = Color(1, 1, 1)

const PADDING = Vector2(0, -8)
const JOB_STEP_SIZE = Vector2(0, 164)

var money_reward = 5

export var steps_min:int = 2
export var steps_max:int = 3
var steps:int
var current_step = 0

onready var JobStep = preload("JobStep.tscn")

func _ready():
    randomize()
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
        
        # init
        var jobStep = JobStep.instance()
        jobStep.init(self)
        
        # calc pos
        
        jobStep.position = cur_pos
        cur_pos -= JOB_STEP_SIZE
        cur_pos -= PADDING
        
        # add
        $Steps.add_child(jobStep)
        
    $Sprite.position = cur_pos
    #position.y -= cur_pos.y
    position.y -= JOB_STEP_SIZE.y/2
    current_step = 0
    enable_step(0)
    
    
func current_step_done():
    current_step += 1
    if current_step >= steps:
        get_tree().current_scene.add_money(money_reward)
    
    $Tween.interpolate_property(self, "position:y", position.y, position.y+JOB_STEP_SIZE.y+PADDING.y, 0.6, Tween.TRANS_EXPO, Tween.EASE_IN, 0.6)
    $Tween.start()
    
    if $Steps.get_child_count() > 0:
        $Steps.get_child(0).enable(true)
    
    
func enable_step(id):
    for i in range($Steps.get_child_count()):
        $Steps.get_child(i).enable((id) == i)
        
        
    
