extends Node2D

onready var DiePreview = preload("res://scenes/die/DiePreview.tscn")
var previews = {}

func _on_DropArea_drop_item(item):
    
    item.taken_by_area()
    
    if previews.has(item.name):
       return 
    
    var preview = DiePreview.instance()
    add_child(preview)
    preview.init(item)
    preview.global_position = item.global_position + Vector2(50, 0)
    previews[item.name] = preview
    
    item.connect("undrop_item", self, "_on_DropArea_undrop_item", [], CONNECT_ONESHOT)
    
    
    
func _on_DropArea_undrop_item(item):
    if previews.has(item.name):
        previews[item.name].destroy()
        previews.erase(item.name)
