extends Node2D

const Dice = preload("res://scenes/die/Die.gd")

const TRANS_TIME = 1
var dragging_die = false

onready var GameScene = preload("GameScene.tscn")
onready var UpgradeScene = preload("UpgradeScene.tscn")
onready var scene_map = {
    "Game": GameScene,
    "Upgrade": UpgradeScene,
   }
var active_scene
var dice = [Dice.D6(), Dice.D6()]


func _ready():
    load_scene(GameScene)
    
func load_scene(Scene):
    # hide Fader
    $Tween.interpolate_property($Background, "modulate:a", 1, 0, TRANS_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $Tween.start()
    
    # clear previous
    if active_scene != null:
        active_scene.queue_free()  
        
    # instance and add new
    active_scene = Scene.instance()
    add_child(active_scene)
    active_scene.start_scene(dice)
    
func end_scene():
    active_scene.end_scene()
    
    $Background.z_index = 4096
    $Background.modulate.a = 0
    
    $Tween.stop_all()
    $Tween.connect("tween_completed", self, "tween_complete", [], CONNECT_ONESHOT)
    $Tween.interpolate_property($Background, "modulate:a", 0, 1, TRANS_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $Tween.start()
    
func tween_complete(_obj, _key):
    var next_scene_name = active_scene.get_next_scene()
    if scene_map.has(next_scene_name):
        load_scene(scene_map[next_scene_name])
        print("Switching to '" + next_scene_name + "'")
    else:
        printerr("Invalid scene name '" + next_scene_name + "'")
    
    
    
    


