@tool 
extends Control

## CLASS DEFINITIONS:

## MBP stands for Mesh-Builder-Plugin
const MBP = preload("uid://c0n3wfy7l2xwm")

var editorPlug : EditorPlugin
var editorSelection : EditorSelection

var meshSelectionMode : int = 0

var spatialGizmoSnapPoint : MeshInstance3D

var selection : Array

var meshEditMode := meshEditModes.off

@onready var shapeCreateAABBMat : Material = preload("uid://djff2euu5td51")

var debugShapeCreate : bool = false

var editorViewport : SubViewport
var editorCamera : Camera3D

var debugSphere : MeshInstance3D

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

## my plugin replacement for _input since the regular one only works in EditorPlugin class
func _receiveInput(event : InputEvent)->void:
	if event is InputEventMouseMotion:
		if debugShapeCreate:
			debug2Dto3D()

func _init():
	# Prevents addon from working while game instance is running
	if !Engine.is_editor_hint():
		return
	
	# Sets selection mode to default selection mode (select object mode)
	meshSelectionMode = 0
	
	editorViewport = EditorInterface.get_editor_viewport_3d(0)
	editorCamera = editorViewport.get_camera_3d()
	
	editorPlug = EditorPlugin.new()
	
	# Connects signal which is emiting every time user selects something in the editor
	# So the dock can change accordingly depending on the situation
	if editorSelection == null:
		editorSelection = EditorInterface.get_selection()
		editorSelection.selection_changed.connect(_SceneTreeSelectionChanged)

## my plugin replacement for _ready since the regular one only works in EditorPlugin class
func _start() -> void:
	# Prevents addon from working while game instance is running
	if !Engine.is_editor_hint():
		return
	
	debugSphere = MeshInstance3D.new()
	editorViewport.add_child(debugSphere)
	debugSphere.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	debugSphere.hide()
	var debugMesh := SphereMesh.new()
	debugMesh.radius = 0.05
	debugMesh.height = 0.1
	debugSphere.mesh = debugMesh

## my plugin replacement for _process since the regular one only works in EditorPlugin class
func _update()->void:
	pass

## sets selection toolbar (selection mode button UI) to specified modeID
func setMeshSelectionMode(modeID : int):
	if modeID > 3 or modeID < 0:
		printerr("Wrong mode id, it will be clamped in range from 0 to 3")
		modeID = clamp(modeID,0,3)
	meshSelectionMode = modeID
	selectionModeChanged.emit(modeID)
	if MBP.toolbar == null:
		return
	MBP.toolbar.get_child(modeID).button_pressed = true

## resets selection toolbar to it's default selection mode
func resetMeshSelectionMode():
	setMeshSelectionMode(0)

## Runs every time user selects something in the editor
func _SceneTreeSelectionChanged():
	# This function won't run if the selection mode toolbar does not exist.
	# Because every time selection is changed this function resets it 
	# into default selection mode.  
	# That's why this function won't run unless the toolbar exist.
	if MBP.toolbar == null:
		return
	
	selection = editorSelection.get_selected_nodes()
	#print("selected elements: ",selection)
	
	# This thing can be used to show clear warnings in the editor
	# outside of the editor's output or debugger dock
	#var toasterTest = EditorInterface.get_editor_toaster()
	#toasterTest.push_toast(str(selection),EditorToaster.SEVERITY_INFO,"")
	
	# if user unselects everything, or selects nothing
	if selection.size() != 1:
		MBP.turnOnBuilderButton.hide()
		resetMeshSelectionMode()
		return
	
	if meshEditMode == meshEditModes.off:
		if selection[0] is MeshInstance3D:
			MBP.turnOnBuilderButton.show()
			#selectionModeToolbar.show()
		else:
			MBP.turnOnBuilderButton.hide()

## Runs when user enters the edit mode
func turnOnMeshEditMode()->void:
	#if !dockAdded:
		#editorPlug.add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR,self)
		#self.show()
	#dockAdded = true
	MBP.spatialEditorToolbar.hide()
	MBP.toolbar.show()
	MBP.exitBuilderModeButton.show()
	for button : Button in MBP.editorTitleBar.get_children():
		if button != MBP.exitBuilderModeButton:
			button.hide()
	MBP.turnOnBuilderButton.hide()
	MBP.spatialOptions.hide()
	MBP.meshSelectionModeButton.show()
	meshEditMode = meshEditModes.edit_mode
	debugShapeCreate = true
	debug2Dto3D()
	#editorPlug.hide_bottom_panel()

## Runs when user exits the edit mode
func turnOffMeshEditMode()->void:
	MBP.toolbar.hide()
	MBP.spatialEditorToolbar.show()
	MBP.turnOnBuilderButton.show()
	MBP.spatialOptions.show()
	for button : Button in MBP.editorTitleBar.get_children():
		button.show()
	MBP.exitBuilderModeButton.hide()
	MBP.meshSelectionModeButton.hide()
	debugSphere.hide()
	debugShapeCreate = false
	meshEditMode = meshEditModes.off
	#self.hide()
	#if dockAdded:
		#editorPlug.remove_control_from_docks(self)
	#dockAdded = false

## Runs when user switch selection mode in UI
func meshSelectionModeChanged(index : int)->void:
	meshEditMode = index

## Called when the plugin is disabled from the list
func onPluginRemove()->void:
	debugSphere.queue_free()
	turnOffMeshEditMode()
	spatialGizmoSnapPoint.queue_free()

func debug2Dto3D()->void:
	debugSphere.show()
	
	var cursorPos2D := editorViewport.get_mouse_position()
	var pos3D = editorCamera.project_position(cursorPos2D,5)
	debugSphere.global_position = pos3D

func generateAABBPreviewMesh(from : AABB) -> ArrayMesh:
	var currentChunkMesh = []
	currentChunkMesh.resize(ArrayMesh.ARRAY_MAX)
	var currentChunkMesh_asVertiecies = []
	currentChunkMesh_asVertiecies.resize(8)
	
	var currentChunkPoints = [
		#currentChunkPos + Vector3(1,1,1) * (maxChunkSize / 2),
		#currentChunkPos + Vector3(1,1,-1) * (maxChunkSize / 2),
		#currentChunkPos + Vector3(-1,1,1) * (maxChunkSize / 2),
		#currentChunkPos + Vector3(-1,1,-1) * (maxChunkSize / 2),
		#currentChunkPos + Vector3(1,-1,1) * (maxChunkSize / 2),
		#currentChunkPos + Vector3(1,-1,-1) * (maxChunkSize / 2),
		#currentChunkPos + Vector3(-1,-1,1) * (maxChunkSize / 2),
		#currentChunkPos + Vector3(-1,-1,-1) * (maxChunkSize / 2),
	]
	
	var currentChunkIndexes_asLines = [
		0,1,
		2,0,
		2,3,
		3,1,
		0,4,
		1,5,
		2,6,
		3,7,
		4,5,
		6,4,
		6,7,
		7,5,
	]
	
	currentChunkMesh[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array(currentChunkPoints)
	currentChunkMesh[ArrayMesh.ARRAY_INDEX] = PackedInt32Array(currentChunkIndexes_asLines)
	
	
	var debugChunk : ArrayMesh = ArrayMesh.new()
	debugChunk.add_surface_from_arrays(Mesh.PRIMITIVE_LINES,currentChunkMesh)
	debugChunk.surface_set_material(0,shapeCreateAABBMat)
	return debugChunk
