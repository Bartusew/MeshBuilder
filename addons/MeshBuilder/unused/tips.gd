@tool
extends EditorPlugin

##IMPORTANT this file CAN be removed because it isn't used anywhere
## it is just a nice list of functions and some notes that can be used for making cool plugins

var node : Control

func function()->void:
	
	##Use this to get one of four 3D viewports from editor
	EditorInterface.get_editor_viewport_3d(0)
	
	##Use this to add node into that top "toolbar" menu in 3D editor
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, node)
	##There are also other places in 3D editor so you aren't limited to just the top one
	#	EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_RIGHT
	#	EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_LEFT
	#	EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM
	
	## ONLY EditorPlugin scripts can run _input _process etc functions
	## So if you want other scripts to check input or run in the background
	## you should connect them with the main plugin script by calling different functions
	## or using signals
	
	## also remember to add @tool at the top of any of the plugin scripts
	
	## Prevents addon from working inside the game
	#	if !Engine.is_editor_hint():
	#		return
	
	## Just like with the 3D viewport use EditorInterface class to get anything out of the editor
	#	for example toaster  EditorInterface.get_editor_toaster() to throw some important notifications to the user
	#	or EditorInterface.get_editor_undo_redo() for undo redo support
	
	## Use this thing to pause code for one process frame
	#	await Engine.get_main_loop().process_frame
	
	## Run expensive logic only once every 2 physics frames here.
	#if Engine.get_physics_frames() % 2 == 0:
		#pass 
	
	## To get Godot Editor's built in icons you should use
	#	EditorInterface.get_base_control().get_theme_icon("icon_name","EditorIcons") 
	
	## Loading and saving settings into EditorSettings
	#var iconSaturation : float = EditorInterface.get_editor_settings().get_setting("interface/theme/icon_saturation")
	## In this case I've tried saving input keycode but it just created an setting option with number instead
	## some actual input setting.. For saving and loading Editor Input settings this PR would be usefull: https://github.com/godotengine/godot-proposals/issues/2024
	#var editorSettings := EditorInterface.get_editor_settings()
	#editorSettings.set_setting("MeshBuilder/Shortcuts/sideToolbarToogleKey",sideToolbarToogleKey)
	## But also maybe you could bother with creating custom file inside
	## some of Godot's editor folder where it stores it's settings files and etc
	## and then via FilePath you could load / save input settings with your custom input settings handler
	
	## Here's a little collection of signals provided by EditorPlugin class:
	#	(ofc plugin is and intance of an EditorPlugin class)
	#	plugin.main_screen_changed - Emits every time you switch the top mode like from 3D to Script and etc
	#		Also works with custom modes added by addons
	#	plugin.scene_changed - Emits every time currently edited scene had some kind of change
	#		There also similar signals for when scene is closed, saved.

## This function returs the HboxContainer that is the parent of buttons used to switch main Godot editor 
##  like the 2D, 3D, Script, Game, Assetlib buttons
func getMainScreenButtons()->HBoxContainer:
	var ctrl : Control = EditorInterface.get_base_control()
	ctrl = ctrl.get_child(0).get_child(0).get_child(2)
	return ctrl

## Not something really incredible to look at
## rather simple function, pass in the root node as argument and type of node
## you are looking for
func searchForNode(root : Node, type : String)->Node:
	if root == null:
		return null
	if root.get_class() == type:
		return root
	for child : Node in root.get_children():
		return searchForNode(child,type)
	return null

## Self explanatory - copies over every stylebox theme override from one control node to another
##	useful when you want to preserve look or theme of control nodes in the editor
func _copy_over_stylebox_overrides(from : Control, to : Control)->void:
	to.add_theme_stylebox_override("focus",from.get_theme_stylebox("focus"))
	to.add_theme_stylebox_override("disabled_mirrored",from.get_theme_stylebox("disabled_mirrored"))
	to.add_theme_stylebox_override("disabled",from.get_theme_stylebox("disabled"))
	to.add_theme_stylebox_override("hover_pressed_mirrored",from.get_theme_stylebox("hover_pressed_mirrored"))
	to.add_theme_stylebox_override("hover_pressed",from.get_theme_stylebox("hover_pressed"))
	to.add_theme_stylebox_override("hover_mirrored",from.get_theme_stylebox("hover_mirrored"))
	to.add_theme_stylebox_override("hover",from.get_theme_stylebox("hover"))
	to.add_theme_stylebox_override("pressed_mirrored",from.get_theme_stylebox("pressed_mirrored"))
	to.add_theme_stylebox_override("pressed",from.get_theme_stylebox("pressed"))
	to.add_theme_stylebox_override("normal_mirrored",from.get_theme_stylebox("normal_mirrored"))
	to.add_theme_stylebox_override("normal",from.get_theme_stylebox("normal"))
