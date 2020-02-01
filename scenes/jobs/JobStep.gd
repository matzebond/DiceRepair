extends Node2D


export var work_min:int = 1
export var work_max:int = 8
var work:int

var job

var dice = []

var has_inited = false

func init(job):
    self.job = job
    
    $Sprite.modulate = job.color
    
    work = rand_range(work_min, work_max+1)
    update_work()
    
    return self
    
func update_work():
    
    # calculate work left
    var work_left = work
    for die in dice:
        var die_value = die.faces[die.face_index]
        if die_value is int:
            work_left -= die_value
        else:
            pass # TODO symbols
            
    if work_left <= 0:
        is_done()
            
    # update view
    if has_inited:
        var a = int($Sprite/Label.text)
        var b = work_left
        if $Tween.is_active():
            $Tween.stop(self, "set_text")
        $Tween.interpolate_method(self, "set_text", a, b, abs(a-b)*0.1)
        $Tween.start()
    else:
        set_text(work_left)
    has_inited = true
    
    

func set_text(val):
    $Sprite/Label.text = str(round(val))
    
func enable(enable):
    $DropArea.is_active = enable
    $Sprite.self_modulate = Color(1,1,1,1) if enable else Color(0.8,0.8,0.8,0.6)
    
func is_done():
    job.current_step_done()
    pass
    
func _on_DropArea_drop_item(die):
    dice.push_back(die)
    update_work()
    
    die.connect("undrop_item", self, "_on_DropArea_undrop_item", [], CONNECT_ONESHOT)
    die.taken_by_area()
    
func _on_DropArea_undrop_item(die):
    dice.erase(die)
    update_work()
