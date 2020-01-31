extends Area2D

signal drop_item(item)

export var is_active:bool = true
    
func drop(die):
    emit_signal("drop_item", die)
    
