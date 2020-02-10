extends Area2D

signal drop_item(item)

export var is_active:bool = true
    
func get_area():
    var area = Rect2(global_position, scale * 2 * Vector2(100,100))
    area.position -= area.size / 2
    return area
    
func drop_into(die):
    emit_signal("drop_item", die) 
