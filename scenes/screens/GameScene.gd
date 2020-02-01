extends Node2D

var game_running = false
var time = 0

func end_scene():
    game_running = false
    time = 0


func start_scene():
    game_running = true
    time = 20
    pass


func get_next_scene():
    return "Upgrade"
