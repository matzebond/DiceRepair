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
        
class SetToolUpgrade extends Upgrade:
    var tuul
    func _init(tuul):
        self.tuul = tuul
        .set_params(10, 0+tuul, "")
    func can_use_on(face):
        return face.type != Die.Broken
    func use_on(face):
        face.type = Die.Tool
        face.value = tuul
        
class SetJokerUpgrade extends Upgrade:
    func _init():
        .set_params(60, 7, "")
    func can_use_on(face):
        return face.type != Die.Broken
    func use_on(face):
        face.type = Die.Joker
        
class SetNumberUpgrade extends Upgrade:
    var value
    func _init(value):
        self.value = value
        .set_params(20, 4, str(value))
    func can_use_on(face):
        return face.type != Die.Broken
    func use_on(face):
        face.type = Die.Number
        face.value = value
        
class PlusDeltaUpgrade extends Upgrade:
    var delta
    func _init(delta):
        self.delta = delta
        .set_params(3 * delta, 5, str(delta))
    func can_use_on(face):
        return face.type == Die.Number
    func use_on(face):
        face.value += delta
        
class MinusDeltaUpgrade extends Upgrade:
    var delta
    func _init(delta):
        self.delta = delta
        .set_params(3 * delta, 6, str(delta))
    func can_use_on(face):
        return face.type == Die.Number and (face.value - delta) >= 1
    func use_on(face):
        face.value -= delta

onready var root = get_tree().current_scene

var upgrade
var toolbench
var hide_button = false

func _ready():
    if not upgrade or (not hide_button and not toolbench):
        printerr("Error in UpgradeButton: upgrade and toolbench must be set before _ready()")
        upgrade = PlusDeltaUpgrade.new(2)

    _set_price(upgrade.price)
    $Icon.frame = upgrade.icon_id
    $Label.text = upgrade.text
    
    if hide_button:
        self.disabled = true
        self.add_stylebox_override("disabled", StyleBoxEmpty.new())
        
func money_changed(money): # Overrides
    if not hide_button:
        .money_changed(money)

func _on_UpgradeButton_pressed():
    var selected_faces = toolbench.get_selected_faces()
    
    if len(selected_faces) != 1:
        root.show_text("Select one Face!", self)
        return
    
    var face = selected_faces[0][0]
    var preview = selected_faces[0][1]
    
    if not upgrade.can_use_on(face):
        root.show_text("Cannot use on this Face!", self)
        return
    
    if not root.try_pay(upgrade.price, preview.global_position):
        # TODO Play sound "not enough money"
        return
    
    upgrade.use_on(face)
    preview.update()
    preview.die.render_face()
    
    
