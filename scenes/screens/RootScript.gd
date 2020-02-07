extends Node2D
const Die = preload("res://scenes/die/Die.gd")
const TutorialScene = preload("TutorialScene.tscn")
const GameScene = preload("GameScene.tscn")
const UpgradeScene = preload("UpgradeScene.tscn")
const UpgradeButton = preload("res://scenes/ugrades/UpgradeButton.gd")
const scene_map = {
    "Tutorial": TutorialScene,
    "Game": GameScene,
    "Upgrade": UpgradeScene,
   }
var active_scene
var next_scene_name

const DICE_MIN_DST = 120
const TRANS_TIME = 1
const START_MONEY = 30

var rng = RandomNumberGenerator.new()
var dice = [Die.D6(), Die.D8(), Die.D8(), Die.D12()]
var upgrades = [UpgradeButton.PlusDeltaUpgrade.new(2), UpgradeButton.PlusDeltaUpgrade.new(4), UpgradeButton.PlusDeltaUpgrade.new(6), UpgradeButton.PlusDeltaUpgrade.new(8)]
var game_running = false
var dragging_die = false
var money = START_MONEY
var game_round = 0
signal money_changed(money)


func _ready():
    randomize()
    rng.randomize()
    restart()
    
func restart():
    dice = [Die.D6(), Die.D8(), Die.D8(), Die.D12()]
    game_running = false
    dragging_die = false
    money = START_MONEY
    game_round = 0
    construct_dice()
    load_scene(TutorialScene)
    
func construct_dice():
    var color =  Color.from_hsv(rand_range(0,0.25), rand_range(0.6, 1), rand_range(0.8, 1))
    for die in dice:
        die.color = color
        color = Color.from_hsv(color.h + 1.0/len(dice), rand_range(0.6, 1), rand_range(0.8, 1))
        
    #place tools on number faces
    var face_len = 0
    for die in dice:
        face_len += len(die.faces)
        
    for tuul in [Die.Hammer, Die.Saw, Die.Ratchet, Die.Drill]:
        var tuul_placed = false
        while not tuul_placed:
            var index = rng.randi_range(0, face_len-1)
            for die in dice:
                if index >= len(die.faces):
                    index -= len(die.faces)
                elif die.faces[index].type == Die.Number:
                    die.faces[index] = Die.Face.new(Die.Tool, tuul)
                    tuul_placed = true
                    break
                else:
                    break
    
func load_scene(Scene):
    # hide Fader
    $Tween.interpolate_property($Fader, "modulate:a", 1, 0, TRANS_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
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
    
func end_scene(next_scene_name=null):
    self.next_scene_name = next_scene_name
    if not next_scene_name:
        self.next_scene_name = active_scene.get_next_scene()
    active_scene.end_scene()
    
    $Fader.z_index = 4096
    $Fader.modulate.a = 0
    
    $Tween.stop_all()
    $Tween.connect("tween_completed", self, "tween_complete", [], CONNECT_ONESHOT)
    $Tween.interpolate_property($Fader, "modulate:a", 0, 1, TRANS_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $Tween.start()
    
func tween_complete(_obj, _key):
    if scene_map.has(next_scene_name):
        load_scene(scene_map[next_scene_name])
        print("Switching to '" + next_scene_name + "'")
    else:
        printerr("Invalid scene name '" + next_scene_name + "'")

func random_die_pos(area, dice_min_dst=DICE_MIN_DST):
    var iter = 0
    var pos
    
    while iter < 1000:
        var x = area.position.x + rand_range(0, area.size.x)
        var y = area.position.y + rand_range(0, area.size.y)
        pos = Vector2(x,y)
        var pos_ok = true
    
        for die in get_tree().get_nodes_in_group("die"):
            if die.last_roll_target_pos and die.last_roll_target_pos.distance_to(pos) < dice_min_dst:
                pos_ok = false
        if pos_ok:
            return pos
        iter += 1
    if iter >= 1000:
        print("Could not find free position")
    return pos
    
const MoneyParticles = preload("res://scenes/particles/MoneyParticles.tscn")
func add_money(delta, position):
    add_child(MoneyParticles.instance().init(
        position, $MoneyParticlePos.position, abs(delta), self, "coin_arrived"))
    
func coin_arrived():
    money += 1
    emit_signal("money_changed", money)

func try_pay(amount, pos=null, then_object=null, then_method=null):
    if money >= amount:
        money -= amount
        if pos:
            add_child(MoneyParticles.instance().init(
                $MoneyParticlePos.position, pos, abs(amount), null, null, then_object, then_method))
        emit_signal("money_changed", money)
        return true
    else:
        return false
    


func can_pay_reroll():
    for die in dice:
        if money >= die.roll_cost:
            return true
    return false
