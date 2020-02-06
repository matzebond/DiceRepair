extends Node2D
const Die = preload("res://scenes/die/Die.gd")
const DiePreview = preload("res://scenes/die/DiePreview.tscn")
var previews = {}

const COSTS_REPAIR = 20
const COSTS_UPGRADE = 20
const COSTS_SWAP = 10


func _ready():
    $Panel.set('custom_styles/panel', $Panel.theme.get_stylebox("DottedPanel", "Panel"))
    
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



func _on_UpgradeButton_pressed():
    var selected_faces = get_selected_faces()
    
    if len(selected_faces) != 1:
        # TODO Play sound "invalid selection"
        return
        
    var preview = selected_faces[0][1]
    var face = selected_faces[0][0]
    
    if face.type == Die.Broken:
        # TODO Play sound "invalid selection"
        return
        
    if not get_tree().current_scene.try_pay(COSTS_UPGRADE, preview.global_position):
        # TODO Play sound "not enough money"
        return
        
    # TODO Play sound "upgrade"
    set_face_random(face, preview)
    update_preview(preview)


func _on_RepairButton_pressed():
    var selected_faces = get_selected_faces()
    
    if len(selected_faces) != 1:
        # TODO Play sound "invalid selection"
        return
    
    var preview = selected_faces[0][1]
    var face = selected_faces[0][0]

    if face.type != Die.Broken:
        # TODO Play sound "invalid selection"
        return
        
    if not get_tree().current_scene.try_pay(COSTS_REPAIR, preview.global_position):
        # TODO Play sound "not enough money"
        return
    
    # TODO Play sound "repaired"
    set_face_random(face, preview)
    update_preview(preview)


func _on_SwapButton_pressed():
    
    var selected_faces = get_selected_faces()
    
    if len(selected_faces) != 2:
        # TODO Play sound "invalid selection"
        return
        
    var face_a = selected_faces[0][0]
    var face_b = selected_faces[1][0]
        
    if not get_tree().current_scene.try_pay(COSTS_SWAP, selected_faces[0][1].global_position):
        # TODO Play sound "not enough money"
        return
        
    # TODO Play sound "switch"
    var type = face_a.type
    var value = face_a.value
    face_a.type = face_b.type
    face_a.value = face_b.value
    face_b.type = type
    face_b.value = value
    
    update_preview(selected_faces[0][1])
    update_preview(selected_faces[1][1])
    
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
        face.value = Die.TOOLS[get_tree().current_scene.rng.randi_range(0, len(Die.TOOLS) - 1)]
    else:
        # Number
        face.type = Die.Number
        face.value = get_tree().current_scene.rng.randi_range(1, len(preview.die.viz_state.faces))

func update_preview(preview):
    preview.update()
    preview.select(null)
