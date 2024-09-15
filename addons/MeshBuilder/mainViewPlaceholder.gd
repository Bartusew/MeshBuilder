extends EditorPlugin

var plugin_control

func _enter_tree():
	plugin_control = Control.new()
	EditorInterface.get_editor_main_screen().add_child(plugin_control)
	plugin_control.hide()

func _has_main_screen():
	return true

func _get_plugin_name():
	return " eda"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
