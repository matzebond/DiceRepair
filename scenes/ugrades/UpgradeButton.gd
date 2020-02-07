extends "PayButton.gd"

const Die = preload("res://scenes/die/Die.tscn")

class Upgrade:
    var price = 0
    var icon_id = 0
    var text
    func set_params(price, icon_id, text):
        self.price = price
        self.icon_id = icon_id
        self.text = text
        
    func can_use_on(face):
        return false
    func use_on(face): # only use when can_use_on() returned true
        pass
        
        
class PlusDeltaUpgrade extends Upgrade:
    var delta
    func _init(delta):
        .set_params(3 * delta, 5, str(delta))
        pass
    func can_use_on(face):
        return face.type == Die.Number
    func use_on(face):
        face.value += delta

var upgrade
func _ready():
    upgrade = PlusDeltaUpgrade.new(2) # delete this

    _set_price(upgrade.price)
    $Icon.frame = upgrade.icon_id
    $Label.text = upgrade.text

func _on_UpgradeButton_pressed():
    pass # Replace with function body.
