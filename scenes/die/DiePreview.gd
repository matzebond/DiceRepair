extends Node2D

onready var Die
const DIE_DST = 80
const EXTRACT_TIME = 0.8
const CONTRACT_TIME = 0.4

var faces = 0
var dummy_dice = []


func init(die):
    var Die = load("res://scenes/die/Die.tscn")
    faces = len(die.faces)
    dummy_dice = []
    for i in range(faces):
        var dupl = Die.instance()
        dupl.init(die.viz_state)
        dupl.block()
        dupl.face_index = i
        dupl.is_dummy = true
        add_child(dupl)
        dummy_dice.push_back(dupl)
        $Tween.interpolate_property(dupl, "position:x", 0, (i+1) * DIE_DST, EXTRACT_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
        $Tween.interpolate_property(dupl, "modulate:a", 0, 1, EXTRACT_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $Tween.start()
    return self
    
    
func destroy():
    $Tween.stop_all()
    $Tween.connect("tween_completed", self, "destroy_completed", [], CONNECT_ONESHOT)
    for i in range(faces):
        var dice = dummy_dice[i]
        $Tween.interpolate_property(dice, "position:x", dice.position.x, 0, CONTRACT_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
        $Tween.interpolate_property(dice, "modulate:a", dice.modulate.a, 0, CONTRACT_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $Tween.start()
    
func destroy_completed(_obj, _key):
    queue_free()
        
