extends Node2D

signal money_changed(money)

var game_running = false
var time = 0
var money = 10


func end_scene():
    game_running = false
    time = 0


func start_scene():
    game_running = true
    time = 200
    emit_signal("money_changed", money)
    pass


func get_next_scene():
    return "Upgrade"

func add_money(delta):
    money += delta
    emit_signal("money_changed", money)
