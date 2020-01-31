extends Sprite


# Declare member variables here. Examples:
onready var label = $Label

signal undrop_item(die)

var faces = []
var state
var rng = RandomNumberGenerator.new()

var mouse_inside = false
onready var pre_drag_pos = self.position
var dragging = false

# Called when the node enters the scene tree for the first time.
func _ready():
    faces = [1, 2, 3, 4, 5, 6]
    rng.randomize()
    roll()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func roll():
    state = rng.randi_range(0, len(faces) - 1)
    label.text = str(faces[state])
    
func _unhandled_input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
        if dragging and !event.pressed:
            dragging = false
            check_dropables()
            
    elif event is InputEventMouseMotion and dragging:
        self.position = event.position

func _on_Area2D_mouse_entered():
    mouse_inside = true


func _on_Area2D_mouse_exited():
    mouse_inside = false


func _on_Area2D_input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        roll()
    
    if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
        if mouse_inside and !dragging and event.pressed:
            dragging = true
            emit_signal("undrop_item", self)
            pre_drag_pos = self.position

func check_dropables():
    
    var min_area = null
    var min_dst = 10000000
    
    for candidate in $Area2D.get_overlapping_areas():
        
        if not candidate.is_in_group("DropArea"):
            continue
        var dst = $Area2D.position.distance_squared_to(candidate.position)
        if dst < min_dst:
            min_area = candidate
            min_dst = dst
        
    if not min_area == null:
        min_area.drop(self)
    else:
        snap_back()
        
func snap_back():
    self.position = pre_drag_pos