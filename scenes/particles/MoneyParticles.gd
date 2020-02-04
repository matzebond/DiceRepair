extends Node2D

var particles_left

var pos_start
var pos_end

var coin_then_obj
var coin_then_method
var done_then_obj
var done_then_method
    
func init(pos_start, pos_end, amount, coin_then_obj=null, coin_then_method=null, done_then_obj=null, done_then_method=null):
    particles_left = amount
    self.pos_start = pos_start
    self.pos_end = pos_end
    
    self.coin_then_obj = coin_then_obj
    self.coin_then_method = coin_then_method
    self.done_then_obj = done_then_obj
    self.done_then_method = done_then_method
    
   
    return self
    
func _ready():
     for i in range(particles_left):
        add_child(init_particle(pos_start, pos_end))
    
onready var MoneyParticle = preload("MoneyParticle.tscn")
func init_particle(pos_start, pos_end):
    return MoneyParticle.instance().init(pos_start, pos_end)

func freed():
    particles_left -= 1
    if coin_then_obj != null:
        coin_then_obj.call(coin_then_method)
    if particles_left <= 0:
        if done_then_obj != null:
            done_then_obj.call(done_then_method)
        queue_free()