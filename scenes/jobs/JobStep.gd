extends Node2D
const Die = preload("res://scenes/die/Die.gd")


export var work_min:int = 1
export var work_max:int = 8

var work_req:int
var work_cur:int
var tools = []

var is_waiting = false
var wait_base
var wait_overshoot
const WAIT_FACTOR_BASE = 4
const WAIT_FACTOR_OVERSHOOT = 0.7

var job

var money_reward = 5

var dice = []

var has_inited = false

onready var sprite_inactive = preload("res://assets/img/jobs/jobstep_inactive.png")
onready var sprite = preload("res://assets/img/jobs/jobstep.png")
onready var sprite_active = preload("res://assets/img/jobs/jobstep_active.png")

func init(job):
    self.job = job
    
    $Sprite.modulate = job.color
    
    for tuul in Die.TOOLS:
        if randf() > 0.9:
            tools.append(tuul)
    
    var i = 0
    for tuul in tools:
        var tex = Sprite.new()
        tex.texture = Die.tool_sprite(tuul)

        $Tools.add_child(tex)

        tex.position.y =  -50 + (100/len(tools)/2.0) + i * (100.0 / len(tools))
        tex.scale = Vector2(1.0/len(tools), 1.0/len(tools))
        i += 1
    
    work_req = rand_range(work_min, work_max+1)
    update_work()
    
    return self
    
func update_work():
    var last_work_cur = work_cur
    # calculate current work
    work_cur = 0
    for die in dice:
        var die_value = die.cur_face().value
        if die_value is int:
            work_cur += die_value
    
    #skip if tool present
    for die in dice:
        for tuul in tools:
            print(die.viz_state.cur_face().type)
            if die.viz_state.cur_face().type == tuul:
                work_cur = work_req
      
    # start wait time      
    if work_cur >= work_req:
        is_waiting = true
        $Sprite.texture = sprite_active
        $DropArea.is_active = false
        wait_base = work_req
        wait_overshoot = work_cur - work_req
        for die in dice:
            die.block()
            
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
    $Sprite.texture = sprite if enable else sprite_inactive


func _process(delta):
    if is_waiting and get_tree().current_scene.game_running:
        if wait_base > 0:
            wait_base = max(0, wait_base - delta * WAIT_FACTOR_BASE)
        else:
            if wait_overshoot > 0:
                wait_overshoot = max(0, wait_overshoot - delta * WAIT_FACTOR_OVERSHOOT)
            else:
                is_done()
                is_waiting = false # prevent duplicate calls
        var a = round(wait_overshoot + wait_base)
        var b = round(wait_base)
        set_text(str(a) + "/" + str(b))
    
    
func is_done():
    
    var scene = get_tree().current_scene
    
    scene.add_money(money_reward)
    
    
    var pos = global_position
    get_parent().remove_child(self)
    scene.add_child(self)
    global_position = pos
    move_to_top()
    $Tween.connect("tween_completed", self, "tween_complete", [], CONNECT_ONESHOT)
    $Tween.interpolate_property(self, "position:x", position.x, position.x + 1000, 1.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
    $Tween.start()
    
    job.current_step_done()
    
    
    for die in dice:
        scene.active_scene.add_die(die)

    get_tree().current_scene.add_money(money_reward)

func tween_complete(_obj, _key):
    self.queue_free()
    
func _on_DropArea_drop_item(die):
    dice.push_back(die)
    
    die.connect("undrop_item", self, "_on_DropArea_undrop_item", [], CONNECT_ONESHOT)
    die.taken_by_area()
    
    update_work()
    
func _on_DropArea_undrop_item(die):
    dice.erase(die)
    update_work()
    
func move_to_top():
    var p = get_parent()
    if p != null:
        var count = p.get_child_count()
        if p.get_child(count - 1) != self:
            p.move_child(self, count - 1)
