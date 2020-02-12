extends Node2D

enum Icons {ICON_TIME, ICON_LEVEL, ICON_MONEY}
const ICON_PATHS = {
    Icons.ICON_TIME : preload("res://assets/img/ui/icon_time.png"),
    Icons.ICON_LEVEL : preload("res://assets/img/ui/icon_level.png"),
    Icons.ICON_MONEY : preload("res://assets/img/ui/icon_coin.png")
}


export(Icons) var icon = Icons.ICON_MONEY
export var text = "" setget _set_text
export var update_on_signal = ""

func _ready():
    if update_on_signal != "":
        get_tree().current_scene.connect(update_on_signal, self, "_set_text")
    update_viz()
    
func _set_text(v):
    text = str(v)
    call_deferred("update_viz")
    
func update_viz():
    $NinePatchRect/HBoxContainer/TextureRect.texture = ICON_PATHS[icon]
    $NinePatchRect/HBoxContainer/Label.text = text
    
