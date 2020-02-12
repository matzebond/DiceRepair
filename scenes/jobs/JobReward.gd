extends "JobElement.gd"

const UpgradeButton = preload("res://scenes/ugrades/UpgradeButton.tscn")
var upgrade

func init(pos, upgrade):
    self.position = pos
    self.upgrade = upgrade
    
func _ready():
    
    if upgrade:
        var inst = UpgradeButton.instance()
        inst.upgrade = upgrade
        inst.hide_button = true
        inst.toolbench = null
        $UpgradeHolder.add_child(inst)
        inst.rect_position -= inst.rect_size / 2.0
        
        nodes_to_mask.append($UpgradeHolder/UpgradeButton/Icon)
        nodes_to_mask.append($UpgradeHolder/UpgradeButton/Label)
        nodes_to_mask.append($UpgradeHolder/UpgradeButton/VBoxContainer/HBoxContainer/MoneyIcon)
        nodes_to_mask.append($UpgradeHolder/UpgradeButton/VBoxContainer/HBoxContainer/Price)
    mask(true)

func enable(enable):
    .enable(enable)
    if enable:
        
        if upgrade != null:
            upgrade()
        
        $Tween.connect("tween_completed", self, "upgrade_unlock_tween_done", [], CONNECT_ONESHOT)
        $Tween.interpolate_property($UpgradeHolder, "scale", Vector2(1,1), Vector2(2,2), 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
        $Tween.interpolate_property($UpgradeHolder, "modulate:a", $UpgradeHolder.modulate.a, 0, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
        $Tween.start()

func upgrade():
    var root = get_tree().current_scene
    root.upgrades.append(upgrade)
    root.upgrade_pool.erase(upgrade)
            
    # tell other rewards to expire 
    for job_reward in get_tree().get_nodes_in_group("JobReward"):
        if job_reward != self:
            job_reward.reward_expired()
            
func reward_expired():
    upgrade = null
    $Tween.interpolate_property($UpgradeHolder, "modulate:a", 1, 0, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
    $Tween.start()
        
func upgrade_unlock_tween_done(_x, _y):
    is_done()
