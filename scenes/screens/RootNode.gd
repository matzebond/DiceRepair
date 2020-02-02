extends Node2D
const Die = preload("res://scenes/die/Die.gd")
onready var TutorialScene = preload("TutorialScene.tscn")
onready var GameScene = preload("GameScene.tscn")
onready var UpgradeScene = preload("UpgradeScene.tscn")
onready var scene_map = {
    "Tutorial": TutorialScene,
    "Game": GameScene,
    "Upgrade": UpgradeScene,
   }
var active_scene

const TRANS_TIME = 1

var dice = [Die.D6(), Die.D8(), Die.D12()]
var game_running = false
var dragging_die = false
var time = 0
var money = 100
signal money_changed(money)


func _ready():
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    var face_sum = 0
    for die in dice:
        face_sum += len(die.faces)
    for tuul in [Die.Hammer, Die.Saw, Die.Ratchet, Die.Drill]:
        var tuul_placed = false
        while not tuul_placed:
            var index = rng.randi_range(0, face_sum-1)
            var die_index = 0
            for die in dice:
                if index >= len(die.faces):
                    index -= len(die.faces)
                elif die.faces[index].type == Die.Number:
                    die.faces[index] = Die.Face.new(tuul)
                    tuul_placed = true
                    break
        
    load_scene(TutorialScene)
    
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
    emit_signal("money_changed", money)
    dragging_die = false
    
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


func add_money(delta):
    money += delta
    emit_signal("money_changed", money)

func can_pay(amount):
    if money >= amount:
        money -= amount
        emit_signal("money_changed", money)
        return true
    else:
        return false
