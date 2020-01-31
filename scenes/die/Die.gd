extends Sprite


# Declare member variables here. Examples:
onready var label = $Label

var faces = []

var rng = RandomNumberGenerator.new()

var mouse_inside = false
var dragging = false

# Called when the node enters the scene tree for the first time.
func _ready():
    faces = [1, 2, 3, 4, 5, 6, "H", "S"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func roll():
    var num = rng.randi_range(0, len(faces) - 1)
    label.text = str(faces[num])
    
func _unhandled_input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
        if dragging and !event.pressed:
            dragging = false
            
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
