extends Node2D

var pos_end:Vector2
var vel_explode:Vector2 = Vector2()

const SPEED_EXPLODE = 30
const SPEED_GATHER = 50

const TIME_EXPLODE_TO_GATHER = 0.5

var time = 0

func init(pos_start, pos_end):
    position = pos_start
    self.pos_end = pos_end
    
    vel_explode = Vector2(SPEED_EXPLODE, 0).rotated(rand_range(0, 2*PI))
    return self


var last_dst = 100000000
func _process(delta):
    time += delta
    
    var vel_a = vel_explode
    var vel_b = Vector2(-SPEED_GATHER, 0).rotated(position.angle_to_point(pos_end))
    
    var mix_b = max(0, min(1, time / TIME_EXPLODE_TO_GATHER))
    
    var vel = (1-mix_b)*vel_a + mix_b*vel_b
    position += vel
    
    var dst = position.distance_squared_to(pos_end)
    if mix_b == 1 and dst >= last_dst:
        get_parent().freed()
        queue_free()
    last_dst = dst
    
    
