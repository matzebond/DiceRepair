extends Node2D

var game_running = true
var time = 20.0

var dragging_die = false

func stop_round():
    game_running = false
    time = 0

func start_round():
    pass
