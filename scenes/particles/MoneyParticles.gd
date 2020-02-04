extends Node2D

var particles_left

func _ready():
    init(Vector2(200, 200), Vector2(500, 400), 10)
    
func init(pos_start, pos_end, amount):
    particles_left = amount
    $pos1.position = pos_start
    $pos2.position = pos_end
    for i in range(amount):
        add_child(init_particle(pos_start, pos_end))
    
onready var MoneyParticle = preload("MoneyParticle.tscn")
func init_particle(pos_start, pos_end):
    return MoneyParticle.instance().init(pos_start, pos_end)

func freed():
    particles_left -= 1
    if particles_left <= 0:
        queue_free()
