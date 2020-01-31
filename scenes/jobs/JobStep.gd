extends Node2D


export var work_min:int = 1
export var work_max:int = 20
var work:int

var job

func init(job):
    self.job = job
    
    $Sprite.modulate = job.color
    
    work = rand_range(work_min, work_max+1)
    $Sprite/Label.text = str(work)
    
    return self

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.



