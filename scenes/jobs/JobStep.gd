extends Node2D

export var work_min:int = 1
export var work_max:int = 8

var work_req:int
var work_cur:int

var is_waiting = false
var time_to_wait_left

var job

var money_reward = 5

var dice = []

var has_inited = false

onready var sprite_done = preload("res://assets/img/jobs/jobstep_done.png")

func init(job):
    self.job = job
    
    $Sprite.modulate = job.color
    
    work_req = rand_range(work_min, work_max+1)
    update_work()
    
    return self
    
func update_work():
    
    var last_work_cur = work_cur
    # calculate work left
    work_cur = 0
    for die in dice:
        var die_value = die.faces[die.face_index]
        if die_value is int:
            work_cur += die_value
        else:
            pass # TODO symbols
      
    # start wait time      
    if work_cur >= work_req:
        is_waiting = true
        $Sprite.texture = sprite_done
        $DropArea.is_active = false
        time_to_wait_left = work_cur
            
    # update view
    if has_inited: # dont animate the first time
        if $Tween.is_active():
            $Tween.stop(self, "set_text")
        $Tween.interpolate_method(self, "set_text_work_cur", last_work_cur, work_cur, abs(last_work_cur-work_cur)*0.1)
        $Tween.start()
    else:
        set_text_work_cur(0)
    has_inited = true
    

func set_text_work_cur(val):
    set_text(str(round(val)) + "/" + str(work_req))

func set_text(text):
    $Label.text = text
    
func enable(enable):
    $DropArea.is_active = enable
    $Sprite.self_modulate = Color(1,1,1,1) if enable else Color(0.8,0.8,0.8,0.6)


func _process(delta):
    if is_waiting:
        time_to_wait_left -= delta
        set_text(str(round(time_to_wait_left)))
        if time_to_wait_left <= 0:
            is_done()
            is_waiting = false # prevent duplicate calls
        
    
    
func is_done():
    job.current_step_done()

    get_tree().current_scene.active_scene.add_money(money_reward)

    self.queue_free()
    for die in dice:
        get_tree().current_scene.active_scene.add_die(die)
    
func _on_DropArea_drop_item(die):
    dice.push_back(die)
    update_work()
    
    die.connect("undrop_item", self, "_on_DropArea_undrop_item", [], CONNECT_ONESHOT)
    die.taken_by_area()
    
func _on_DropArea_undrop_item(die):
    dice.erase(die)
    update_work()
