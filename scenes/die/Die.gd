extends Sprite


# Declare member variables here. Examples:
onready var label = $Label

signal undrop_item(die)

var faces = []
var state
var rng = RandomNumberGenerator.new()

var mouse_inside = false
var dragging = false
onready var pre_drag_pos = self.position
var drag_offset = Vector2()

const SNAP_BACK_SPEED = 0.0002


func _ready():
    faces = [1, 2, 3, 4, 5, 6, "F"]
    rng.randomize()
    roll()

    
func _unhandled_input(event):
    if event is InputEventMouseMotion and dragging :
        self.position = event.position + drag_offset    
    if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
        if !event.pressed and dragging:
            dragging = false
            get_tree().current_scene.dragging_die = false
            drop()
        if event.pressed and mouse_inside and !get_tree().current_scene.dragging_die:
            dragging = true
            get_tree().current_scene.dragging_die = true
            start_drag()


func _on_Area2D_mouse_entered():
    mouse_inside = true


func _on_Area2D_mouse_exited():
    mouse_inside = false


func _on_Area2D_input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        roll()
        
    return


func roll():
    state = rng.randi_range(0, len(faces) - 1)
    label.text = str(faces[state])

 
func start_drag():
    emit_signal("undrop_item", self)
    drag_offset = self.position - get_tree().root.get_mouse_position()
    pre_drag_pos = self.position
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
        var dst = $Area2D.position.distance_squared_to(candidate.position)
        if min_area == null or (dst < min_dst and candidate.z_index >= min_area.z_index):
            min_area = candidate
            min_dst = dst
        
    if not min_area == null:
        min_area.drop(self)
        play_tween_make_trans()
    else:
        snap_back()


func snap_back():
    var dist = (pre_drag_pos - position).length()
    $Tween.interpolate_property(self, "position", position, pre_drag_pos, dist*SNAP_BACK_SPEED, Tween.TRANS_EXPO, Tween.EASE_IN)
    $Tween.start()
    
func play_tween_make_trans():
    var c = modulate
    var c_a = Color(c.r, c.g, c.b, 1)
    var c_b = Color(c.r, c.g, c.b, 0.65)
    $Tween.interpolate_property(self, "modulate", c_a, c_b, 0.4, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
    $Tween.start()
    
func play_tween_make_opaque():
    var c = modulate
    var c_a = Color(c.r, c.g, c.b, 1)
    var c_b = Color(c.r, c.g, c.b, 0.65)
    $Tween.interpolate_property(self, "modulate", c_b, c_a, 0.4, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
    $Tween.start()
