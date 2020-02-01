extends Node2D



func _on_DropArea_drop_item(item):
    item.taken_by_area()
