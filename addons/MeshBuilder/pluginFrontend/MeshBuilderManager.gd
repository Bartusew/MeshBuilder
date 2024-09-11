@tool
extends Control
class_name MeshBuilderManager

var selectionMode : int = 0
var editorPlug : EditorPlugin
var editorSelection : EditorSelection
var selection : Array
var selectionModeToolbar : Control
var builder : MeshBuilderNode
var selectedNode : Node
var vertexGizmo_plugin : EditorNode3DGizmoPlugin

var meshEditOptionsIcons : Array[Texture2D]
@onready var meshEditButtons : ItemList = $MeshEditorWindow/MeshEditionOptions

signal selectionModeChanged(new_mode : int) 

func connectSelectionChanged_toVertexPlugin():
	self.connect("selectionModeChanged",Callable(vertexGizmo_plugin,"selectModeChanged"))
	vertexGizmo_plugin.meshBuilderDock = self

func _init():
	# Prevents addon from working while game instance is running
	if !Engine.is_editor_hint():
		return
	
	# Sets selection mode to default selection mode (select object mode)
	selectionMode = 0
	
	editorPlug = EditorPlugin.new()
	
	# Connects signal which is emiting every time user selects something in the editor
	# So the dock can change accordingly depending on the situation
	if editorSelection == null:
		editorSelection = editorPlug.get_editor_interface().get_selection()
		editorSelection.connect("selection_changed", Callable(self,"_SceneTreeSelectionChanged"))

# adds icon element to a grid of tools in dock
func loadIconsIntoMeshEditField():
	meshEditButtons.add_icon_item(meshEditOptionsIcons[0])

# sets a specified selection mode
# 0 - select object mode
# 1 - select face mode
# 2 - select edge mode
# 3 - select vertex mode
func setSelectionMode(modeID : int):
	if modeID > 3 or modeID < 0:
		printerr("Wrong mode id, it will be clamped in range from 0 to 3")
		modeID = clamp(modeID,0,3)
	selectionMode = modeID
	selectionModeChanged.emit(modeID)
	if selectionModeToolbar == null:
		return
	selectionModeToolbar.get_child(modeID).button_pressed = true

# resets selection toolbar to it's default selection mode
func resetSelectionMode():
	setSelectionMode(0)

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
		_userDoesNotSelectedAnything()
		selectionModeToolbar.hide()
		resetSelectionMode()
		return
	
	# if user selected one element
	if selection.size() == 1:
		if selection[0] is MeshBuilderNode:
			# if selected element is MeshBuilderNode
			print(selection[0])
			builder = selection[0]
			selectionModeToolbar.show()
			if builder.mesh == null:
				_userSelectEmptyMeshInstance()
			else:
				_userSelectMeshInstance()
		else:
			#if user selected something else
			selectedNode = selection[0]
			_userNotSelectMeshInstance()
			selectionModeToolbar.hide()
			resetSelectionMode()
	else:
		#if user selected multiple elements
		_userSelectedTooManyNodes()
		selectionModeToolbar.hide()
		resetSelectionMode()

# Those five functions switch the look of the dock depending on what is selected in the editor

func _userDoesNotSelectedAnything():
	%NothingIsSelected.show()
	%Selected_NOT_meshInstance.hide()
	%EmptyMeshInstanceSelected.hide()
	%ToManySelectedNodes.hide()
	%MeshEditorWindow.hide()

func _userNotSelectMeshInstance():
	%NothingIsSelected.hide()
	%Selected_NOT_meshInstance.show()
	%EmptyMeshInstanceSelected.hide()
	%ToManySelectedNodes.hide()
	%MeshEditorWindow.hide()

func _userSelectEmptyMeshInstance():
	%NothingIsSelected.hide()
	%Selected_NOT_meshInstance.hide()
	%EmptyMeshInstanceSelected.show()
	%ToManySelectedNodes.hide()
	%MeshEditorWindow.hide()

func _userSelectedTooManyNodes():
	%NothingIsSelected.hide()
	%Selected_NOT_meshInstance.hide()
	%EmptyMeshInstanceSelected.hide()
	%ToManySelectedNodes.show()
	%MeshEditorWindow.hide()

func _userSelectMeshInstance():
	%NothingIsSelected.hide()
	%Selected_NOT_meshInstance.hide()
	%EmptyMeshInstanceSelected.hide()
	%ToManySelectedNodes.hide()
	%MeshEditorWindow.show()

#-----------------------------------------------------------------------------------------------

#func manageBuilderNode():
#	var editMesh : Mesh = builder.mesh
#	print("root: ",get_tree().get_edited_scene_root())
#	get_tree().get_edited_scene_root().add_child(builder)
#	if builder.get_parent() != get_tree().get_edited_scene_root():
#		get_tree().get_edited_scene_root().add_child(builder)
#	editorSelection.add_node(builder)
#	editorSelection.remove_node(mInst)
#	print("builder: ",builder)
#	selection = editorSelection.get_selected_nodes()
#	print("selected elements: ",selection)

func createNewChildMeshInstance():
	var root = selection[0]
	var newInstance := MeshBuilderNode.new()
	newInstance.name = "MeshBuilderNode"
	root.add_child(newInstance)
	newInstance.set_owner(get_tree().get_edited_scene_root())

func createNewMeshInstance():
#	for instance in get_tree().get_edited_scene_root().get_children():
#		if instance is MeshInstance3D:
#			instance.free()
	var newInstance := MeshBuilderNode.new()
	newInstance.name = "MeshBuilderNode"
	get_tree().get_edited_scene_root().add_child(newInstance)
	newInstance.set_owner(get_tree().get_edited_scene_root())
