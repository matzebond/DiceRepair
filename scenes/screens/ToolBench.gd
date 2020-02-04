extends Node2D
const Die = preload("res://scenes/die/Die.gd")
const DiePreview = preload("res://scenes/die/DiePreview.tscn")
var previews = {}

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
    var selected_faces = []
    for preview in previews.values():
        var face = preview.selected_face()
        if face:
            selected_faces.append([face, preview])

    if len(selected_faces) == 0:
        return

    match len(selected_faces):
        1:  # randomize face
            if not get_tree().current_scene.try_pay(20, selected_faces[0][1].global_position):
                return
            var preview = selected_faces[0][1]
            var face = selected_faces[0][0]
            if not face:
                return
            match face.type:
                Die.Number:
                    if randf() < 0.8:
                        face.value = get_tree().current_scene.rng.randi_range(1, len(preview.die.viz_state.faces))
                    else:
                        face.type = Die.Tool
                        face.value = Die.TOOLS[get_tree().current_scene.rng.randi_range(0, len(Die.TOOLS) - 1)]
                Die.Tool:
                    if randf() < 0.8:
                        face.type = Die.TOOLS[get_tree().current_scene.rng.randi_range(0, len(Die.TOOLS) - 1)]
                    else:
                        face.type = Die.Number
                        face.value = get_tree().current_scene.rng.randi_range(1, len(preview.die.viz_state.faces))
                _:
                    face.type = Die.Number
                    #face.value = get_tree().current_scene.rng.randi_range(1, len(preview.die.viz_state.faces))

        
        2: # swap faces
            if not get_tree().current_scene.try_pay(10, selected_faces[0][1].global_position):
                return
            var face_a = selected_faces[0][0]
            var face_b = selected_faces[1][0]
            if not face_a or not face_b:
                return
            var type = face_a.type
            var value = face_a.value
            face_a.type = face_b.type
            face_a.value = face_b.value
            face_b.type = type
            face_b.value = value

    for obj in selected_faces:
            obj[1].update()
            obj[1].select(null)
