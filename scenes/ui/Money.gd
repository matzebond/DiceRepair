extends Label

func _on_GameScene_money_changed(money):
    text = str(money) + " G"
