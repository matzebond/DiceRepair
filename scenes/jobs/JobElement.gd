extends Node2D

signal done

onready var nodes_to_mask = []

var money_reward = 0

func _ready():
    nodes_to_mask.append($Sprite)
    nodes_to_mask.append($Inactive)
    
func mask(enable):
    for node in nodes_to_mask:
        node.light_mask = 1024 if enable else 1

func can_finish(dice):
    return true
    

const A_INACTIVE = 0.35
const A_ACTIVE = 0.0
func enable(enable):
    var a = A_ACTIVE if enable else A_INACTIVE
    $Tween.interpolate_property($Inactive, "color:a", $Inactive.color.a, a, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.start()

func is_done(_obj=null, _key=null):
    mask(false)
    animate_out()
    get_tree().current_scene.add_money(money_reward, position)
    emit_signal("done", self)

func animate_out():
    var scene = get_tree().current_scene
    var pos = global_position
    get_parent().remove_child(self)
    scene.add_child(self)
    global_position = pos
    move_to_top()
    $Tween.connect("tween_completed", self, "tween_complete", [], CONNECT_ONESHOT)
    $Tween.interpolate_property(self, "position:x", position.x, position.x + 1000, 1.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
    $Tween.interpolate_property($Sprite, "modulate:a", 1, 0, 1.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
    $Tween.start()

func tween_complete(_obj, _key):
    self.queue_free()
    
func move_to_top():
    var p = get_parent()
    if p != null:
        var count = p.get_child_count()
        if p.get_child(count - 1) != self:
            p.move_child(self, count - 1)
