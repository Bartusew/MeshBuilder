@tool class_name MeshBuilderManager extends Control

var editorPlug : EditorPlugin
var editorSelection : EditorSelection

var meshSelectionMode : int = 0

var selection : Array
var selectionModeToolbar : Control
var editMeshButton : Button

var meshEditOptionsIcons : Array[Texture2D]
@onready var meshEditButtons : ItemList = $MeshEditionOptions

enum meshSelectionModes
{
	object,
	face,
	edge,
	vertex
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
func loadIconsIntoMeshEditField():
	meshEditButtons.add_icon_item(meshEditOptionsIcons[0])


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
	if selection.size() == 0:
		selectionModeToolbar.hide()
		editMeshButton.hide()
		resetMeshSelectionMode()
		return
	
	if selection[0] is MeshInstance3D:
		editMeshButton.show()
		#selectionModeToolbar.show()
