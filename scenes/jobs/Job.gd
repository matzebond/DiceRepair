extends Node2D

export var color:Color = Color(0.8, 0.6, 0.12)

const PADDING = Vector2(0, 5)
const JOB_STEP_SIZE = Vector2(0, 224)

export var steps_min:int = 1
export var steps_max:int = 3
var steps:int

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
    var cur_pos = Vector2(0,0)
    for i in range(steps):
        
        # init
        var jobStep = JobStep.instance()
        jobStep.init(self)
        
        # calc pos
        cur_pos += PADDING
        jobStep.position = cur_pos + JOB_STEP_SIZE / 2
        cur_pos += JOB_STEP_SIZE
        
        # add
        $Steps.add_child(jobStep)
        
    enable_step(steps-1)
    
func enable_step(id):
    for i in range($Steps.get_child_count()):
        $Steps.get_child(i).enable(id == i)
        
        
    
