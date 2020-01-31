extends Node2D


export var work_min:int = 1
export var work_max:int = 20
var work:int

var job

var dice = []

func init(job):
    self.job = job
    
    $Sprite.modulate = job.color
    
    work = rand_range(work_min, work_max+1)
    update_work()
    
    return self
    
func update_work():
    var work_left = work
    for die in dice:
        var die_value = die.faces[die.state]
        if die_value is int:
            work_left -= die_value
        else:
            pass # TODO symbols
    $Sprite/Label.text = str(work_left)

func _on_DropArea_drop_item(die):
    dice.push_back(die)
    update_work()
    
    die.connect("undrop_item", self, "_on_DropArea_undrop_item", [], CONNECT_ONESHOT)
    
func _on_DropArea_undrop_item(die):
    dice.erase(die)
    update_work()
