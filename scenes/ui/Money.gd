extends Label

func _ready():
    get_tree().current_scene.connect("money_changed", self, "money_changed")

func money_changed(money):
    text = str(money) + " G"
