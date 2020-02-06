extends Node2D


func _ready():
    var p = $ColorRect/PanelThin
    p.set('custom_styles/panel', p.theme.get_stylebox("ThinPanel", "Panel"))
    
    p = $ColorRect/PanelDotted
    p.set('custom_styles/panel', p.theme.get_stylebox("DottedPanel", "Panel"))
