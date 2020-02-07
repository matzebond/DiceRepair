extends "PayButton.gd"

const Die = preload("res://scenes/die/Die.gd")

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
        self.delta = delta
        .set_params(3 * delta, 5, str(delta))
    func can_use_on(face):
        return face.type == Die.Number
    func use_on(face):
        face.value += delta

var upgrade
var toolbench

func _ready():
    if not upgrade or not toolbench:
        printerr("Error in UpgradeButton: upgrade and toolbench must be set before _ready()")
        upgrade = PlusDeltaUpgrade.new(2)

    _set_price(upgrade.price)
    $Icon.frame = upgrade.icon_id
    $Label.text = upgrade.text

func _on_UpgradeButton_pressed():
    var selected_faces = toolbench.get_selected_faces()
    
    if len(selected_faces) != 1:
        # TODO Play sound "invalid selection"
        return
    
    var face = selected_faces[0][0]
    var preview = selected_faces[0][1]
    
    if not upgrade.can_use_on(face):
        # TODO Play sound "invalid selection"
        return
    
    if not get_tree().current_scene.try_pay(upgrade.price, preview.global_position):
        # TODO Play sound "not enough money"
        return
    
    upgrade.use_on(face)
    preview.update()
    preview.die.render_face()
    
    
