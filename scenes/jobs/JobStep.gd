extends "JobElement.gd"
const Die = preload("res://scenes/die/Die.gd")

const WORK_TIME_FACTOR = 0.1
const EXCESS_WAIT_FACTOR = 1

var work_req:int
var cur_work_req:int
var tools = []

var dice = []

func init(pos, work):
    self.position = pos
    self.work_req = work
    self.money_reward = 5
    
func _ready():
    for tuul in Die.TOOLS:
        if randf() > 0.82:
            tools.append(tuul)
    
    var i = 0
    var width = 196.0
    for tuul in tools:
        var tex = Sprite.new()
        tex.texture = Die.tool_sprite(tuul)

        $Tools.add_child(tex)
        nodes_to_mask.append(tex)
    
        tex.position.x =  -width/2 + (width/len(tools)/2.0) + i * (width / len(tools))
        tex.scale = Vector2(0.5, 0.5)
        i += 1
    
    nodes_to_mask.append($Label)
    mask(true)
    
    cur_work_req = work_req
    set_text_work_cur(cur_work_req)

func enable(enable):
    $DropArea.is_active = enable
    .enable(enable)

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
            work += 1
        elif face.type == Die.Joker:
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
    
    if cur_work_req <= 0:
        for die in dice:
            die.block()
            
    # start excess
    if cur_work_req < 0:
        $Tween.connect("tween_completed", self, "start_excess", [cur_work_req], CONNECT_ONESHOT)
        $DropArea.is_active = false
    elif cur_work_req == 0:
        $Tween.connect("tween_completed", self, "is_done", [], CONNECT_ONESHOT)


func set_text_work_cur(val):
    $Label.text = str(floor(val))
   
func start_excess(_obj, _key, excess):
    for i in range(abs(excess)):
        break_face()
    $Tween.interpolate_method(self, "set_text_work_cur", excess, 0, -excess * EXCESS_WAIT_FACTOR)
    $Tween.connect("tween_completed", self, "is_done", [], CONNECT_ONESHOT)
    $Tween.start()

func break_face():
    # find all non-broken faces
    var non_broken_faces = []
    for die in dice:
        for i in range(len(die.viz_state.faces)):
             non_broken_faces.append([die, i])
    # return if everything already broken
    if len(non_broken_faces) == 0:
        return
    # select random face and break it
    var i = get_tree().current_scene.rng.randi_range(0, len(non_broken_faces)-1)
    non_broken_faces[i][0].break_face(non_broken_faces[i][1])
    
func is_done(_obj, _key):
    .is_done(_obj, _key)
    get_tree().current_scene.active_scene.add_die(dice)
    
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
    
