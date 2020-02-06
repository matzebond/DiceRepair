extends Node2D

const Die = preload("res://scenes/die/Die.tscn")
const DIE_DST = 50
const EXTRACT_TIME = 0.3
const CONTRACT_TIME = 0.15

var faces = 0
var dummy_dice = []

var die
var selectable = false
var selected = null
var selected_face_id = -1


func init(die, selectable = false):
    self.die = die
    self.global_position = die.global_position
    self.selectable = selectable
    faces = len(die.viz_state.faces)
    var angle = 2*PI / faces
    var cur_angle = -PI/2.0
    dummy_dice = []
    var index = die.viz_state.face_index
    for i in range(faces):
        var dupl = Die.instance()
        dupl.init(die.viz_state)
        dupl.viz_state.face_index = i
        dupl.dummy = true
        add_child(dupl)
        dummy_dice.push_back(dupl)
        dupl.modulate.a = 0
        dupl.scale = 0.6 * Vector2(1,1)
        var target_pos = polar2cartesian(DIE_DST*2, cur_angle)
        cur_angle += angle
        $Tween.interpolate_property(dupl, "position", Vector2(), target_pos, EXTRACT_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
        $Tween.interpolate_property(dupl, "modulate:a", 0, 1, EXTRACT_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $Tween.start()
    die.viz_state.face_index = index
    return self
    
    
func destroy():
    $Tween.stop_all()
    $Tween.connect("tween_completed", self, "destroy_completed", [], CONNECT_ONESHOT)
    for i in range(faces):
        var dice = dummy_dice[i]
        $Tween.interpolate_property(dice, "position", dice.position, Vector2(), CONTRACT_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.interpolate_property(dice, "modulate:a", dice.modulate.a, 0, CONTRACT_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $Tween.start()
    
func update():
    var children = get_children()
    for i in range(1,len(children)):
        children[i].viz_state.face_index = i-1
        children[i].render_face()
    
func select(die):
    if not selectable:
        return
    if selected:
        selected.modulate -= Color(0.2, 0.2, 0.2)
    if die == selected:
        selected = null
        selected_face_id = -1
        return
    selected = die
    selected_face_id = get_children().find(die) - 1
    if selected:
        selected.modulate += Color(0.2, 0.2, 0.2)


func selected_face():
    if not selectable or selected_face_id < 0:
        return null
    return selected.viz_state.faces[selected_face_id]
    
func destroy_completed(_obj, _key):
    queue_free()
