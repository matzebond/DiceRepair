extends Sprite


enum {Number, Hammer, Drill, Ratchet, Saw}
const TOOLS = [Hammer, Drill, Ratchet, Saw]

const hammer_sprite = preload("res://assets/img/tools/hammer.png")
const drill_sprite = preload("res://assets/img/tools/drill.png")
const ratchet_sprite = preload("res://assets/img/tools/ratchet.png")
const saw_sprite = preload("res://assets/img/tools/saw.png")

static func tool_sprite(tuul):
    match tuul:
            Hammer: return hammer_sprite
            Drill: return drill_sprite
            Ratchet: return ratchet_sprite
            Saw: return saw_sprite

class Face:
    var type = Number
    var value = 1
    
    func _init(type, value = null):
        self.type = type
        self.value = value

class DieState:
    var sprite
    var faces
    var roll_cost
    var color
    var face_index
    var sprite_scale

    func _init(dic):
        self.sprite = dic.sprite
        self.faces = dic.faces
        self.roll_cost = dic.roll_cost
        self.color = dic.color
        self.face_index = 0
        self.sprite_scale = dic.sprite_scale
        
    func cur_face():
        return faces[face_index]
        


static func D6(col = null):
    if not col:
        col = random_color()
    return DieState.new({
            "sprite": load("res://assets/img/dice/dice_quad.png"), 
            "faces": [Face.new(Number, 1),Face.new(Number, 2),Face.new(Number, 3),Face.new(Number, 4),Face.new(Number, 5),Face.new(Number, 6)],
            "roll_cost":  6, 
            "color": col,
            "sprite_scale": 0.73})
    
static func D8(col = null):
    if not col:
        col = random_color()
    return DieState.new({
            "sprite": load("res://assets/img/dice/dice_tri.png"), 
            "faces": [Face.new(Number, 1),Face.new(Number, 2),Face.new(Number, 3),Face.new(Number, 4),Face.new(Number, 5),Face.new(Number, 6),Face.new(Number, 7),Face.new(Number, 8)],
            "roll_cost":  8, 
            "color": col,
            "sprite_scale": 0.47})
    
static func D12(col = null):
    if not col:
        col = random_color()
    return DieState.new({
            "sprite": load("res://assets/img/dice/dice_quint.png"), 
            "faces": [Face.new(Number, 1),Face.new(Number, 2),Face.new(Number, 3),Face.new(Number, 4),Face.new(Number, 5),Face.new(Number, 6),Face.new(Number, 7),Face.new(Number, 8),Face.new(Number, 9),Face.new(Number, 10),Face.new(Number, 11),Face.new(Number, 12)],
            "roll_cost":  12, 
            "color": col,
            "sprite_scale": 0.76})
    
static func random_color():
    return Color(randf(),randf(), randf(), 1)



enum {Default, Taken, Blocked, Snapping, Dragging, Rolling}
var state = Default
var is_dummy = false
var viz_state: DieState

onready var number = $Number
onready var tools = $Tool

signal undrop_item(die)

var rng = RandomNumberGenerator.new()

var mouse_inside = false
onready var pre_drag_pos = self.position
var drag_offset = Vector2()
const SNAP_BACK_SPEED = 0.0002

var last_roll_time = -1
const ANIM_ROLLS = 20
const ANIM_DIST = 250

func init(state: DieState):
    viz_state = state
    self.texture = state.sprite
    self.modulate = state.color
    return self

func _ready():
    rng.randomize()
    var s = viz_state.sprite_scale
    $Tool.scale = Vector2(s, s)
    render_face()

func _process(delta):
    if state == Snapping and self.position == pre_drag_pos:
        state = Default


func _unhandled_input(event):
    if event is InputEventMouseMotion and state == Dragging:
        self.position = event.position + drag_offset

    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
        if !event.pressed and state == Dragging:
            state = Default
            get_tree().current_scene.dragging_die = false
            drop()
        if event.pressed and mouse_inside and (state == Default or state == Taken) and !get_tree().current_scene.dragging_die:
            state = Dragging
            get_tree().current_scene.dragging_die = true
            start_drag()

    if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
        if mouse_inside and state == Default and get_tree().current_scene.can_pay(viz_state.roll_cost):
            position = get_tree().current_scene.active_scene.random_die_pos()
            roll()
            get_tree().set_input_as_handled()




func _on_Area2D_mouse_entered():
    mouse_inside = true


func _on_Area2D_mouse_exited():
    mouse_inside = false


func roll():
    last_roll_time = -1
    state = Rolling
    play_tween_make_opaque()
    
    var anim_time = 2 + randf()
    
    $Tween.interpolate_property(self, "scale", Vector2(1.8, 1.8), Vector2(1, 1), anim_time, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
    $Tween.interpolate_property(self, "modulate:a", 0, 1, anim_time/3, Tween.TRANS_SINE, Tween.EASE_OUT)
    $Tween.interpolate_property(self, "rotation", (2*randf()-1)*2*PI, 0, anim_time, Tween.TRANS_SINE, Tween.EASE_OUT)
    
    $Tween.interpolate_property(self, "position", calc_roll_start_pos(), position, anim_time, Tween.TRANS_SINE, Tween.EASE_OUT)
    $Tween.start()
    
    
    $Tween.interpolate_method(self, "rolling", 0, ANIM_ROLLS, anim_time, Tween.TRANS_EXPO, Tween.EASE_OUT)
    $Tween.start()

func calc_roll_start_pos():
    var end = position
    var angle = randf()*2*PI
    var end_to_start = Vector2(ANIM_DIST, 0).rotated(angle)
    var start = end + end_to_start
    return start

func rolling(time):
    time = ceil(time)
    if time > last_roll_time:
        last_roll_time = time
        viz_state.face_index = rng.randi_range(0, len(viz_state.faces) - 1)
        render_face()
            
        if time == ANIM_ROLLS:
            state = Default
            $Tween.stop(self, "rolling")
            
func cur_face():
    return viz_state.cur_face()

func render_face():
    if cur_face().type == Number:
        number.text = str(cur_face().value)
        number.visible = true
        tools.visible = false
    else:
        tools.texture = tool_sprite(cur_face().type)
        tools.visible = true
        number.visible = false
        
func start_drag():
    emit_signal("undrop_item", self)
    drag_offset = self.position - get_tree().root.get_mouse_position()
    if state == Snapping and self.position == pre_drag_pos:
        pre_drag_pos = self.position
    else:
        $Tween.stop(self, "position")
    play_tween_make_opaque()
    move_to_top()


func move_to_top():
    var p = get_parent()
    if p != null:
        var count = p.get_child_count()
        if p.get_child(count - 1) != self:
            p.move_child(self, count - 1)


func drop():
    var min_area = null
    var min_dst = 10000000
    
    for candidate in $Area2D.get_overlapping_areas():
        if not candidate.is_in_group("DropArea"):
            continue
        if not candidate.is_active:
            continue
        var dst = position.distance_squared_to(candidate.global_position)
        if min_area == null or (dst < min_dst and candidate.z_index >= min_area.z_index):
            min_area = candidate
            min_dst = dst
        
    if not min_area == null:
        min_area.drop(self)
    else:
        snap_back()

func block():
    state = Blocked
    
# dropped into & used by a drop area
# DieArea does not "take" die
func taken_by_area(make_trans = true):
    state = Taken
    if make_trans:
        play_tween_make_trans()


func snap_back():
    var dist = (pre_drag_pos - position).length()
    state = Snapping
    $Tween.interpolate_property(self, "position", position, pre_drag_pos, dist*SNAP_BACK_SPEED, Tween.TRANS_EXPO, Tween.EASE_IN)
    $Tween.start()
    
func play_tween_make_trans():
    $Tween.interpolate_property(self, "modulate:a", 1, .65, 0.4, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
    $Tween.start()
    
func play_tween_make_opaque():
    $Tween.interpolate_property(self, "modulate:a", .65, 1, 0.4, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
    $Tween.start()
