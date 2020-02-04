extends Node2D
const Die = preload("res://scenes/die/Die.gd")

const sprite_inactive = preload("res://assets/img/jobs/jobstep_inactive.png")
const sprite_default = preload("res://assets/img/jobs/jobstep.png")
const sprite_active = preload("res://assets/img/jobs/jobstep_active.png")

const WORK_TIME_FACTOR = 0.1
const EXCESS_WAIT_FACTOR = 1

signal done

export var work_min:int = 2
export var work_max:int = 12

var work_req:int
var cur_work_req:int
var tools = []

var money_reward = 5

var dice = []

func init(pos, color):
    position = pos
    $Sprite.modulate = color
    
    for tuul in Die.TOOLS:
        if randf() > 0.82:
            tools.append(tuul)
    
    var i = 0
    var width = 196.0
    for tuul in tools:
        var tex = Sprite.new()
        tex.texture = Die.tool_sprite(tuul)

        $Tools.add_child(tex)
    
        tex.position.x =  -width/2 + (width/len(tools)/2.0) + i * (width / len(tools))
        tex.scale = Vector2(0.5, 0.5)
        i += 1
    
    work_req = rand_range(work_min, work_max+1)
    cur_work_req = work_req
    set_text_work_cur(cur_work_req)
    
    return self


func _process(delta):
    pass


func calc_work(dice):
    var work = 0
    for die in dice:
        var face = die.cur_face()
        if face.type == Die.Number:
            work += face.value
        elif face.type == Die.Tool:
            for tuul in tools:
                if face.value == tuul:
                    return work_req
    return work
    
func can_finish(dice):
    return calc_work(dice) >= work_req
    
func update_work():
    var last_work_req = cur_work_req
    # calculate current work
    cur_work_req = work_req - calc_work(self.dice)
           
    # update view
    if $Tween.is_active():
        $Tween.stop(self, "set_text_work_cur")
    var work_dif = last_work_req - cur_work_req
    $Tween.interpolate_method(self, "set_text_work_cur", last_work_req, cur_work_req, abs(work_dif)*WORK_TIME_FACTOR)
    $Tween.start()
    
    # start excess
    if cur_work_req < 0:
        $Tween.connect("tween_completed", self, "start_excess", [cur_work_req], CONNECT_ONESHOT)
        for die in dice:
            die.block()
        $DropArea.is_active = false
    elif cur_work_req == 0:
        $Tween.connect("tween_completed", self, "is_done", [], CONNECT_ONESHOT)


func set_text_work_cur(val):
    $Label.text = str(floor(val))
    
func enable(enable):
    $DropArea.is_active = enable
    $Sprite.texture = sprite_default if enable else sprite_inactive
        
func start_excess(_obj, _key, excess):
    for i in range(abs(excess)):
        break_face()
    $Tween.interpolate_method(self, "set_text_work_cur", excess, 0, -excess * EXCESS_WAIT_FACTOR)
    $Tween.connect("tween_completed", self, "is_done", [], CONNECT_ONESHOT)
    $Tween.start()
    
func break_face():
    var face_len = 0
    for die in dice:
        face_len += len(die.viz_state.faces)
    var broken = false
    while not broken:
            var index = get_tree().current_scene.rng.randi_range(0, face_len-1)
            for die in dice:
                if index >= len(die.viz_state.faces):
                    index -= len(die.viz_state.faces)
                elif die.viz_state.faces[index].type != Die.Broken:
                    die.viz_state.faces[index].type = Die.Broken
                    broken = true
                    break
                else:
                    break

func is_done(_obj, _key):
    $Sprite.texture = sprite_default
    var scene = get_tree().current_scene
    
    animate_out()
    
    emit_signal("done", self)
    
    scene.active_scene.add_die(dice)

    scene.add_money(money_reward)
    
func animate_out():
    var scene = get_tree().current_scene
    var pos = global_position
    get_parent().remove_child(self)
    scene.add_child(self)
    global_position = pos
    move_to_top()
    $Tween.connect("tween_completed", self, "tween_complete", [], CONNECT_ONESHOT)
    $Tween.interpolate_property(self, "position:x", position.x, position.x + 1000, 1.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
    $Tween.interpolate_property($Sprite, "modulate:a", 1, 0, 1.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
    $Tween.start()

func tween_complete(_obj, _key):
    self.queue_free()
    
func _on_DropArea_drop_item(die):
    # reject illegal dice
    var new_dice = dice.duplicate()
    new_dice.append(die)
    if calc_work(dice) == calc_work(new_dice):
        die.snap_back()
        return

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
