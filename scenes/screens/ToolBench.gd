extends Node2D
const Die = preload("res://scenes/die/Die.gd")
const DiePreview = preload("res://scenes/die/DiePreview.tscn")
const UpgradeButton = preload("res://scenes/ugrades/UpgradeButton.tscn")
var previews = {}

const COSTS_REPAIR = 20
const COSTS_UPGRADE = 20
const COSTS_SWAP = 10

onready var root = get_tree().current_scene

func _ready():
    $Panel.set('custom_styles/panel', $Panel.theme.get_stylebox("DottedPanel", "Panel"))
    
    for upgrade in root.upgrades:
        var inst = UpgradeButton.instance()
        inst.upgrade = upgrade
        inst.toolbench = self
        $CenterContainer/Upgrades.add_child(inst)
    
func _on_DropArea_drop_item(item):
    
    item.taken_by_area()
    
    if previews.has(item.name):
       return 
    
    var preview = DiePreview.instance()
    add_child(preview)
    preview.init(item, true)
    previews[item.name] = preview
    
    item.connect("undrop_item", self, "_on_DropArea_undrop_item", [], CONNECT_ONESHOT)
    
func _on_DropArea_undrop_item(item):
    if previews.has(item.name):
        previews[item.name].destroy()
        previews.erase(item.name)


func _on_RepairButton_pressed():
    var selected_faces = get_selected_faces()
    
    if len(selected_faces) != 1:
        # TODO Play sound "invalid selection"
        root.show_text("Select one Face!", $RepairButton)
        return
    
    var preview = selected_faces[0][1]
    var face = selected_faces[0][0]

    if face.type != Die.Broken:
        # TODO Play sound "invalid selection"
        root.show_text("Nothing to repair!", $RepairButton)
        return
        
    if not .try_pay(COSTS_REPAIR, preview.global_position):
        # TODO Play sound "not enough money"
        return
    
    # TODO Play sound "repaired"
    face.restore_face()
    update_preview(preview)
    preview.die.render_face()


func _on_SwapButton_pressed():
    
    var selected_faces = get_selected_faces()
    
    if len(selected_faces) != 2:
        root.show_text("Select 2 Faces!", $SwapButton)
        return
        
    var face_a = selected_faces[0][0]
    var face_b = selected_faces[1][0]
        
    if not root.try_pay(COSTS_SWAP, selected_faces[0][1].global_position):
        # TODO Play sound "not enough money"
        return
        
    # TODO Play sound "switch"
    face_a.swap(face_b)
    
    update_preview(selected_faces[0][1])
    update_preview(selected_faces[1][1])
    selected_faces[0][1].die.render_face()
    selected_faces[1][1].die.render_face()
    
func get_selected_faces():
    var selected_faces = []
    for preview in previews.values():
        var face = preview.selected_face()
        if face:
            selected_faces.append([face, preview])
    return selected_faces
    
func set_face_random(face, preview):
    var prob_for_tool = 0.2
    
    if face.type == Die.Tool:
        prob_for_tool = 0.8
    
    if randf() < prob_for_tool:
        # Tool
        face.type = Die.Tool
        face.value = Die.TOOLS[root.rng.randi_range(0, len(Die.TOOLS) - 1)]
    else:
        # Number
        face.type = Die.Number
        face.value = root.rng.randi_range(1, len(preview.die.viz_state.faces))

func update_preview(preview):
    preview.update()
    preview.select(null)
