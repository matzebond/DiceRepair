extends Area2D

signal drop_item(item)

export var is_active:bool = true


func _ready():
    
    connect("drop_item", self, "dropped_item")
    
    emit_signal("drop_item", "Löl")
    
func dropped_item(item):
    print(item)
