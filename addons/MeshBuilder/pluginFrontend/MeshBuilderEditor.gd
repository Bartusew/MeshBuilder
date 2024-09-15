@tool class_name MeshBuilderEditor extends Control

var editorPlug : EditorPlugin
var editorSelection : EditorSelection

var meshSelectionMode : int = 0

var spatialGizmoSnapPoint : MeshInstance3D

var selection : Array
var spatialEditorToolbar : HFlowContainer
var selectionModeToolbar : Control
var editorTitleBar : HBoxContainer

var exitMeshBuilderButton : Button
var turnOnBuilderButton : Button
var meshSelectionModeButton : OptionButton
var spatialOptions : MenuButton

var meshEditOptionsIcons : Array[Texture2D]

var meshEditMode := meshEditModes.off


enum meshEditModes
{
	off,
	object_mode,
	edit_mode
}

enum meshSelectionModes
{
	vertex,
	edge,
	face
}

signal selectionModeChanged(new_mode : int) 

func _init():
	# Prevents addon from working while game instance is running
	if !Engine.is_editor_hint():
		return
	
	# Sets selection mode to default selection mode (select object mode)
	meshSelectionMode = 0
	
	editorPlug = EditorPlugin.new()
	
	# Connects signal which is emiting every time user selects something in the editor
	# So the dock can change accordingly depending on the situation
	if editorSelection == null:
		editorSelection = editorPlug.get_editor_interface().get_selection()
		editorSelection.connect("selection_changed", Callable(self,"_SceneTreeSelectionChanged"))

# adds icon element to a grid of tools in dock
#func loadIconsIntoMeshEditField():
	#meshEditButtons.add_icon_item(meshEditOptionsIcons[0])


func setMeshSelectionMode(modeID : int):
	if modeID > 3 or modeID < 0:
		printerr("Wrong mode id, it will be clamped in range from 0 to 3")
		modeID = clamp(modeID,0,3)
	meshSelectionMode = modeID
	selectionModeChanged.emit(modeID)
	if selectionModeToolbar == null:
		return
	selectionModeToolbar.get_child(modeID).button_pressed = true

# resets selection toolbar to it's default selection mode
func resetMeshSelectionMode():
	setMeshSelectionMode(0)

# runs every time user selects something in the editor
func _SceneTreeSelectionChanged():
	# This function won't run if the selection mode toolbar does not exist.
	# Because every time selection is changed this function resets it 
	# into default selection mode.  
	# That's why this function won't run unless the toolbar exist.
	if selectionModeToolbar == null:
		return
	
	selection = editorSelection.get_selected_nodes()
	print("selected elements: ",selection)
	
	# if user unselects everything, or selects nothing
	if selection.size() != 1:
		turnOnBuilderButton.hide()
		resetMeshSelectionMode()
		return
	
	if meshEditMode == meshEditModes.off:
		if selection[0] is MeshInstance3D:
			turnOnBuilderButton.show()
			#selectionModeToolbar.show()


func turnOnMeshEditMode()->void:
	#if !dockAdded:
		#editorPlug.add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR,self)
		#self.show()
	#dockAdded = true
	spatialEditorToolbar.hide()
	selectionModeToolbar.show()
	exitMeshBuilderButton.show()
	for button : Button in editorTitleBar.get_children():
		if button != exitMeshBuilderButton:
			button.hide()
	turnOnBuilderButton.hide()
	spatialOptions.hide()
	meshSelectionModeButton.show()
	meshEditMode = meshEditModes.edit_mode
	#editorPlug.hide_bottom_panel()

func turnOffMeshEditMode()->void:
	selectionModeToolbar.hide()
	spatialEditorToolbar.show()
	turnOnBuilderButton.show()
	spatialOptions.show()
	for button : Button in editorTitleBar.get_children():
		button.show()
	exitMeshBuilderButton.hide()
	meshSelectionModeButton.hide()
	meshEditMode = meshEditModes.off
	#self.hide()
	#if dockAdded:
		#editorPlug.remove_control_from_docks(self)
	#dockAdded = false

func meshSelectionModeChanged(index : int)->void:
	meshEditMode = index
