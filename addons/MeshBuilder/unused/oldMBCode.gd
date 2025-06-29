extends Node

# Boiler plate code to apply all overrides into a control node
func _add_theme_stylebox_override(to : Control, style : StyleBox)->void:
	to.add_theme_stylebox_override("focus",style)
	to.add_theme_stylebox_override("disabled_mirrored",style)
	to.add_theme_stylebox_override("disabled",style)
	to.add_theme_stylebox_override("hover_pressed_mirrored",style)
	to.add_theme_stylebox_override("hover_pressed",style)
	to.add_theme_stylebox_override("hove_mirrored",style)
	to.add_theme_stylebox_override("hover",style)
	to.add_theme_stylebox_override("pressed_mirrored",style)
	to.add_theme_stylebox_override("pressed",style)
	to.add_theme_stylebox_override("normal_mirrored",style)
	to.add_theme_stylebox_override("normal",style)
