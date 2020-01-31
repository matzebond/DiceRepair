extends Sprite


# Declare member variables here. Examples:
onready var label = $Label

var faces = []

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
    faces = [1, 2, 3, 4, 5, 6, "H", "S"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func roll():
    var num = rng.randi_range(0, len(faces) - 1)
    label.text = str(faces[num])
    
func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.pressed:
            roll()
