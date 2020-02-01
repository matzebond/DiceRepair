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
    self.add_child(die)
    die.roll()


func get_next_scene():
    return "Upgrade"

func add_money(delta):
    money += delta
    emit_signal("money_changed", money)
