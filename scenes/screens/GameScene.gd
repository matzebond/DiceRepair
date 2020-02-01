extends Node2D
const Die = preload("res://scenes/die/Die.tscn")

signal money_changed(money)

var game_running = false
var time = 0
var money = 10


func end_scene():
    game_running = false
    time = 0


func start_scene(dice):
    game_running = true
    time = 20
    emit_signal("money_changed", money)
    for die in dice:
        var die_inst = Die.instance().init(die[0], die[1], die[2])
        self.add_die(die_inst)
        
        
func add_die(die):
    die.position = random_die_pos()
    if die.get_parent() == null:
        self.add_child(die)
    die.roll()
    
func random_die_pos():
    var area = Rect2($DieArea.global_position, $DieArea.scale * Vector2(100,100))
    area.position -= area.size / 2
    var x = area.position.x + rand_range(0, area.size.x)
    var y = area.position.y + rand_range(0, area.size.y)
    return Vector2(x,y)


func get_next_scene():
    return "Upgrade"

func add_money(delta):
    money += delta
    emit_signal("money_changed", money)
