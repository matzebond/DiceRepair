tool
extends Button

export var price = 0 setget _set_price

func _ready():
    if not Engine.is_editor_hint():
        get_tree().current_scene.connect("money_changed", self, "money_changed")
    
func _on_PayButton_draw():
    $VBoxContainer/CenterContainer/Label.text = text
    
func _set_price(v):
    $VBoxContainer/HBoxContainer/Price.text = str(v)
    price = v

func money_changed(money):
    disabled = money < price
        
