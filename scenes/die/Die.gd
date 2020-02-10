extends Sprite
onready var DiePreview = load("res://scenes/die/DiePreview.tscn")

const roll1 = preload("res://assets/sounds/roll1.ogg")
const roll2 = preload("res://assets/sounds/roll2.ogg")
const roll3 = preload("res://assets/sounds/roll3.ogg")
const ROLLS = [roll1, roll2]

enum { Number, Tool, Joker, Broken }
enum { Hammer, Drill, Ratchet, Saw }
const TOOLS = [Hammer, Drill, Ratchet, Saw]

const hammer_sprite = preload("res://assets/img/tools/hammer.png")
const drill_sprite = preload("res://assets/img/tools/drill.png")
const ratchet_sprite = preload("res://assets/img/tools/ratchet.png")
const saw_sprite = preload("res://assets/img/tools/saw.png")
const joker_sprite = preload("res://assets/img/tools/joker.png")

static func tool_sprite(tuul):
    match tuul:
            Hammer: return hammer_sprite
            Drill: return drill_sprite
            Ratchet: return ratchet_sprite
            Saw: return saw_sprite

class Face:
    var type = Number
    var value = 1
    var type_pre_break = null # previous type 
    
    func _init(type, value):
        self.type = type
        self.value = value
        self.type_pre_break = type

    func break_face():
        if type != Broken:
            type_pre_break = type
        type = Broken

    func restore_face(): # must be called to repair
        if type != Broken:
            printerr("Tried repairing face, but it is not broken"); return
        type = type_pre_break

    func swap(other: Face):
        var type = self.type
        var value = self.value
        var type_pre_break = self.type_pre_break
        self.type = other.type
        self.value = other.value
        self.type_pre_break = other.type_pre_break
        other.type = type
        other.value = value
        other.type_pre_break = type_pre_break


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
            "roll_cost":  10, 
            "color": col,
            "sprite_scale": 0.73})
    
static func D8(col = null):
    if not col:
        col = random_color()
    return DieState.new({
            "sprite": load("res://assets/img/dice/dice_tri.png"), 
            "faces": [Face.new(Number, 1),Face.new(Number, 2),Face.new(Number, 3),Face.new(Number, 4),Face.new(Number, 5),Face.new(Number, 6),Face.new(Number, 7),Face.new(Number, 8)],
            "roll_cost":  10, 
            "color": col,
            "sprite_scale": 0.47})
    
static func D12(col = null):
    if not col:
        col = random_color()
    return DieState.new({
            "sprite": load("res://assets/img/dice/dice_quint.png"), 
            "faces": [Face.new(Number, 1),Face.new(Number, 2),Face.new(Number, 3),Face.new(Number, 4),Face.new(Number, 5),Face.new(Number, 6),Face.new(Number, 7),Face.new(Number, 8),Face.new(Number, 9),Face.new(Number, 10),Face.new(Number, 11),Face.new(Number, 12)],
            "roll_cost":  10, 
            "color": col,
            "sprite_scale": 0.76})
    
static func random_color():
    return Color.from_hsv(randf(), rand_range(0.6, 1), rand_range(0.7, 1))


enum { Default, Rolling, Dragging, Snapping, Preview, Taken, Blocked }
var dummy = false
var state = Default
var viz_state: DieState

signal undrop_item(die)

var rng = RandomNumberGenerator.new()

var mouse_inside = false
var last_mouse_pos = Vector2()
var last_mouse_time = 0
var preview = null
var HOVER_MOUSE_THRESHOLD = 0.1
var HOVER_TIME_THRESHOLD = 0.75
onready var pre_drag_pos = self.position
var drag_offset = Vector2()
const SNAP_BACK_SPEED = 0.0002

var last_roll_time = -1
const ANIM_ROLLS = 20
const ANIM_DIST = 250

func init(state: DieState):
    viz_state = state
    self.texture = state.sprite
    self.self_modulate = state.color
    return self

func _ready():
    rng.randomize()
    var s = viz_state.sprite_scale
    $Tool.scale = Vector2(s, s)
    render_face()

func _process(delta):
    var mouse_diff = (get_viewport().get_mouse_position() - last_mouse_pos).length() * delta

    if mouse_diff < HOVER_MOUSE_THRESHOLD:
        if mouse_inside:
            var time_diff = OS.get_ticks_msec() - last_mouse_time
            if time_diff/1000.0 > HOVER_TIME_THRESHOLD:
                if state == Default:
                    change_state(Preview)
    else:
        if state == Preview:
            change_state(Default)
        last_mouse_time = OS.get_ticks_msec()
    last_mouse_pos = get_viewport().get_mouse_position()
    

func can_be_dragged():
    return not dummy and (state == Default or state == Taken
        or state == Snapping or state == Preview) \
        and not get_tree().current_scene.dragging_die

func can_be_rolled():
    return not dummy and (state == Default or state == Preview)

func _input(event):
    if event is InputEventMouseMotion or event is InputEventScreenDrag:
        if state == Dragging:
            position = event.position + drag_offset

    # lifting finger leaves die
    if event is InputEventScreenTouch and not event.pressed:
        if mouse_inside:
            mouse_inside = false

    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
        or (event is InputEventScreenTouch):
            if !event.pressed and state == Dragging:
                change_state(Default)

func _on_Area2D_input_event(viewport, event, shape_idx):
    if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT) \
        or (event is InputEventScreenTouch):
            
        # b/c lifting finger leaves die this is needed
        if event.pressed and not mouse_inside:
            mouse_inside = true

        if event.pressed and mouse_inside and can_be_dragged():
            change_state(Dragging)

        if event.pressed and mouse_inside and dummy:
            get_parent().select(self)
            get_tree().set_input_as_handled()

    if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
        and event.pressed and mouse_inside and not dummy:
            try_roll(last_roll_area)
            get_tree().set_input_as_handled()

func reroll_payment_received():
    get_tree().current_scene.active_scene.add_die(self)


func _on_Area2D_mouse_entered():
    mouse_inside = true

func _on_Area2D_mouse_exited():
    mouse_inside = false

func _on_Area2D_area_entered(area):
    pass

func _on_Area2D_area_exited(area):
    pass

var last_roll_area = null
var roll_start_pos
var roll_target_pos
var last_roll_target_pos = null

# only rolls if can_be_rolled() and enough money
func try_roll(area):
    if can_be_rolled():
        if get_tree().current_scene.game_running:
            if (get_tree().current_scene.try_pay(viz_state.roll_cost, position, self, "reroll_payment_received")):
                roll(area)
                return true
        else:
            roll(area)
            return true
    return false
    
func roll(area):
    roll_target_pos = get_tree().current_scene.random_die_pos(area)
    change_state(Rolling)
    last_roll_area = area
    
func start_roll():
    last_roll_time = -1
    # target index
    viz_state.face_index = rng.randi_range(0, len(viz_state.faces) - 1)

    play_tween_make_opaque()
    
    var anim_time = 2 + randf()
    
    if last_roll_target_pos == null:
        roll_start_pos = calc_roll_start_pos(roll_target_pos)
        $Tween.interpolate_property(self, "scale", Vector2(1.8, 1.8), Vector2(1, 1), anim_time, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
        $Tween.interpolate_property(self, "modulate:a", 0, 1, anim_time/3, Tween.TRANS_SINE, Tween.EASE_OUT)
        $Tween.interpolate_property(self, "rotation", (2*randf()-1)*2*PI, 0, anim_time, Tween.TRANS_SINE, Tween.EASE_OUT)
    else:
        roll_start_pos = last_roll_target_pos
        #$Tween.interpolate_property(self, "scale", Vector2(1.8, 1.8), Vector2(1, 1), anim_time, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
        #$Tween.interpolate_property(self, "modulate:a", 0, 1, anim_time/3, Tween.TRANS_SINE, Tween.EASE_OUT)
        $Tween.interpolate_property(self, "rotation", 0, (2*(randi()%2)-1) * 2*PI, anim_time, Tween.TRANS_SINE, Tween.EASE_OUT)
        
    last_roll_target_pos = roll_target_pos
    $Tween.interpolate_property(self, "position", roll_start_pos, roll_target_pos, anim_time, Tween.TRANS_SINE, Tween.EASE_OUT)
    $Tween.start()
    
    $Tween.interpolate_method(self, "interpolate_rolling", 0, ANIM_ROLLS, anim_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
    $Tween.connect("tween_completed", self, "rolling_complete")
    $Tween.start()
    
    yield(get_tree().create_timer(randf() * 0.1), "timeout")
    $AudioStreamPlayer.stream = ROLLS[get_tree().current_scene.rng.randi_range(0, len(ROLLS)-1)]
    $AudioStreamPlayer.play()

func calc_roll_start_pos(end_pos):
    var angle = randf()*2*PI
    var end_to_start = Vector2(ANIM_DIST, 0).rotated(angle)
    var start = end_pos + end_to_start
    return start

func interpolate_rolling(time):
    time = ceil(time)
    if time > last_roll_time:
        last_roll_time = time
        render_face(rng.randi_range(0, len(viz_state.faces) - 1))
        
func rolling_complete(_key, _value):
    if _value == ":interpolate_rolling":
        change_state(Default)
        render_face()
        $Tween.disconnect("tween_completed", self, "rolling_complete")
            
func cur_face():
    return viz_state.cur_face()

func render_face(index=null):
    if not index:
        index = viz_state.face_index
    var face = viz_state.faces[index]
    if face.type == Number:
        $Number.text = str(face.value)
        $Number.visible = true
        $Tool.visible = false
    elif face.type == Tool:
        $Tool.texture = tool_sprite(face.value)
        $Tool.visible = true
        $Number.visible = false
    elif face.type == Joker:
        $Tool.texture = joker_sprite
        $Tool.visible = true
        $Number.visible = false
    else:
        $Number.text = "X"
        $Number.visible = true
        $Tool.visible = false
        
func start_drag():
    get_tree().current_scene.dragging_die = true
    emit_signal("undrop_item", self)
    drag_offset = position - get_viewport().get_mouse_position()
    if state != Snapping:
        pre_drag_pos = position
    else:
        $Tween.disconnect("tween_completed", self, "end_snap_back")
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
        min_area.drop_into(self)
        return Default
    else:
        return Snapping

func block():
    last_roll_target_pos = position
    next_change_state(Blocked)
    
# dropped into & used by a drop area
# DieArea does not "take" die
func taken_by_area(make_trans = true):
    next_change_state(Taken)
    if make_trans:
        play_tween_make_trans()


func snap_back():
    var dist = (pre_drag_pos - position).length()
    $Tween.interpolate_property(self, "position", position, pre_drag_pos, dist*SNAP_BACK_SPEED, Tween.TRANS_EXPO, Tween.EASE_IN)
    $Tween.connect("tween_completed", self, "end_snap_back", [], CONNECT_ONESHOT)
    $Tween.start()

func end_snap_back(_key, _value):
    next_change_state(Default) # next needed b/c waiting for Area2D update
    
func play_tween_make_trans():
    $Tween.interpolate_property(self, "modulate:a", 1, .65, 0.4, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
    $Tween.start()
    
func play_tween_make_opaque():
    $Tween.interpolate_property(self, "modulate:a", .65, 1, 0.4, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
    $Tween.start()

func start_hover():
    preview = DiePreview.instance()
    add_child(preview)
    preview.init(self)
    
func stop_hover():
    if preview:
        preview.destroy()
        preview = null
        
func break_face(face_index):
    viz_state.faces[face_index].break_face()
    render_face()
    # TODO start destruction animation

func next_change_state(next_state):
    yield(get_tree(), "idle_frame") # important do prevent dropping-taking loop
    change_state(next_state)
    
func change_state(next_state):
    if state == next_state or dummy:
        return

    var old_state = state

    match old_state:
        Preview:
            stop_hover()
        Dragging:
            get_tree().current_scene.dragging_die = false
            last_roll_target_pos = position
            next_state = drop()
        Snapping:
            next_state = drop()
    
    if state != old_state:
        return

    state = next_state
    
    match next_state:
        Preview:
            start_hover()
        Dragging:
            start_drag()
        Rolling:
            start_roll()
        Snapping:
            snap_back()
