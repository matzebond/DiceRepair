extends Sprite

# static shit


static func D6(col = null):
    if not col:
        col = random_color()
    return {"sprite": load("res://assets/img/dice/dice_quint.png"), 
            "faces": [1,2,3,4,5,6],
            "cost":  6, 
            "color": col}
    
static func D8(col = null):
    if not col:
        col = random_color()
    return {"sprite": load("res://assets/img/dice/dice_quint.png"), 
            "faces": [1,2,3,4,5,6,7,8],
            "cost":  8, 
            "color": col}
    
static func D12(col = null):
    if not col:
        col = random_color()
    return {"sprite": load("res://assets/img/dice/dice_quint.png"), 
            "faces": [1,2,3,4,5,6,7,8,9,10,11,12],
            "cost":  12, 
            "color": col}
    
static func random_color():
    return Color(randf(),randf(), randf(), 1)



enum {Default, Taken, Snapping, Dragging, Rolling}
var state = Default
# Declare member variables here. Examples:
onready var label = $Label

signal undrop_item(die)

var sprite
var faces = []
var face_index = 0
var rng = RandomNumberGenerator.new()
var roll_cost

var mouse_inside = false
onready var pre_drag_pos = self.position
var drag_offset = Vector2()
const SNAP_BACK_SPEED = 0.0002

var last_roll_time = -1
const ANIM_ROLLS = 20

#func _init():
    
    
func init(state):
    self.texture = state.sprite
    self.faces = state.faces
    self.roll_cost = state.cost
    self.modulate = state.color
    return self

func _ready():
    rng.randomize()
    if not faces or faces.empty():
        faces = [1, 2, 3, 4, 5, 6]
        roll_cost = 6
        roll()


func _process(delta):
    if state == Snapping and self.position == pre_drag_pos:
        state = Default


func _unhandled_input(event):
    if event is InputEventMouseMotion and state == Dragging:
        self.position = event.position + drag_offset

    if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
        if !event.pressed and state == Dragging:
            state = Default
            get_tree().current_scene.dragging_die = false
            drop()
        if event.pressed and mouse_inside and (state == Default or state == Taken) and !get_tree().current_scene.dragging_die:
            state = Dragging
            get_tree().current_scene.dragging_die = true
            start_drag()

    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        if mouse_inside and state == Default and get_tree().current_scene.can_pay(roll_cost):
            roll()



func _on_Area2D_mouse_entered():
    mouse_inside = true


func _on_Area2D_mouse_exited():
    mouse_inside = false


func roll():
    last_roll_time = -1
    state = Rolling
    play_tween_make_opaque()
    $Tween.interpolate_method(self, "rolling", 0, ANIM_ROLLS, 2 + randf(), Tween.TRANS_EXPO, Tween.EASE_OUT)
    $Tween.start()

func rolling(time):
    time = ceil(time)
    if time > last_roll_time:
        last_roll_time = time
        face_index = rng.randi_range(0, len(faces) - 1)
        label.text = str(faces[face_index])
        if time == ANIM_ROLLS:
            state = Default
            $Tween.stop(self, "rolling")
 
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
