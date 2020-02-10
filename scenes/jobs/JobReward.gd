extends "JobElement.gd"

const UpgradeButton = preload("res://scenes/ugrades/UpgradeButton.tscn")
var upgrade

func init(pos, upgrade):
    self.position = pos
    self.upgrade = upgrade
    
func _ready():
    var inst = UpgradeButton.instance()
    inst.upgrade = upgrade
    inst.hide_button = true
    inst.toolbench = null
    add_child_below_node($Sprite, inst)
    inst.rect_position -= inst.rect_size / 2.0
    
    nodes_to_mask.append($UpgradeButton/Icon)
    nodes_to_mask.append($UpgradeButton/Label)
    nodes_to_mask.append($UpgradeButton/VBoxContainer/HBoxContainer/MoneyIcon)
    nodes_to_mask.append($UpgradeButton/VBoxContainer/HBoxContainer/Price)
    mask(true)

func enable(enable):
    .enable(enable)
    if enable:
        
        if upgrade != null:
            get_tree().current_scene.upgrades.append(upgrade)
            
            # tell other rewards to expire 
            for job_reward in get_tree().get_nodes_in_group("JobReward"):
                if job_reward != self:
                    job_reward.reward_expired()
        
        $Tween.connect("tween_completed", self, "upgrade_unlock_tween_done", [], CONNECT_ONESHOT)
        $Tween.interpolate_property($UpgradeButton, "rect_scale", Vector2(1,1), Vector2(2,2), 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
        $Tween.interpolate_property($UpgradeButton, "rect_position", $UpgradeButton.rect_position, $UpgradeButton.rect_position - $UpgradeButton.rect_size / 2.0, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
        $Tween.interpolate_property($UpgradeButton, "modulate:a", $UpgradeButton.modulate.a, 0, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
        $Tween.start()
        
func reward_expired():
    upgrade = null
    $Tween.interpolate_property($UpgradeButton, "modulate:a", 1, 0, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
    $Tween.start()
        
func upgrade_unlock_tween_done(_x, _y):
    is_done(null, null)
