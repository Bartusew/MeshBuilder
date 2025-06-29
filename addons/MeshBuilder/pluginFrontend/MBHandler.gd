@tool
extends Node

## CLASS DEFINITIONS:

## MBP stands for Mesh-Builder-Plugin
const MBP = preload("uid://c0n3wfy7l2xwm")
const MouseHoverEditor = preload("uid://bsre3ybg4sjgs")

## This class is used to handle any input relative stuff related to Mesh Builder

var sideToolbarToogleKey : Key = KEY_T
var isSideBarKeyJustPressed : bool = true

var sideBarVisibility : bool = false

var toolbarButtonGroup : ButtonGroup

var godotMenuToolbar : HBoxContainer

## If scene doesn't have any WorldEnviroment node
## this boolean will be true and then every time new node is added into the
## scene tree then function will check if the just created node is want we are
## looking for then will switch false if not then it will remain true
var _pendingSearchForEnviroment : bool
## And the same story with this variable but for DirectionalLight3D node
var _pendingSearchForLight : bool

var _dirLightEditorButton : Button
var _worldEnvEditorButton : Button
## This button with 3 dots that have this popup for quick light and env settings
var _lightEnvEditorButton : Button
var _lightEnvEditorVSep : VSeparator



#region Checking Edited Scene Change
var _prevSceneRoot : Node
var _currSceneRoot : Node
var _currSceneRootIsNULL : bool = false
signal sceneChanged(root : Node)

## Because a of Godot 4.4.1 EditorPlugin.scene_changed don't emit when opening fresh new scene
## when previously opened "scene" was empty see: https://github.com/godotengine/godot/issues/97427
##  so as a workaround I've created my own function to check it and emit my custom signal
##
## This function should be called every process frame or physics frame
func checkCurrentSceneChange()->void:
	_currSceneRoot = EditorInterface.get_edited_scene_root()
	#print(_currSceneRoot == null and !_currSceneRootIsNULL == false)
	if _currSceneRoot == null and !_currSceneRootIsNULL:
		_currSceneRootIsNULL = true
		sceneChanged.emit(null)
		return
	if _prevSceneRoot != _currSceneRoot:
		_prevSceneRoot = _currSceneRoot
		_currSceneRootIsNULL = false
		sceneChanged.emit(_currSceneRoot)
#endregion

##List of all godot built in tools (at least those that my plugin will snath into the sidebar)
enum godotBuiltinTools{
	Selection,
	Move,
	Rotate,
	Scale,
	Ruler
}

##List of indexes where originally Godot tools are located
# indexes are kinda wrong?? becasue Rotate in theory should have index 3
# and scale index 4... but otherwise for some reason in plugin removal process
# if those indexes were in the "logical" order then in the end button in the 
# top menu toolbar would have messed up order :/
var godotToolsIndexTable : Dictionary[godotBuiltinTools,int] = {
		godotBuiltinTools.Selection : 0,
		godotBuiltinTools.Move : 2,
		godotBuiltinTools.Rotate : 4,
		godotBuiltinTools.Scale : 3,
		godotBuiltinTools.Ruler : 11
}

class toolbarEmptyElement:
	pass

class toolbarTool extends toolbarEmptyElement:
	var icon : Texture2D
	var title : String
	
	func _init(Title : String,IconPath : String)->void:
		title = Title
		if IconPath[0] == "@":
			IconPath = IconPath.lstrip("@")
			icon = EditorInterface.get_base_control().get_theme_icon(IconPath,"EditorIcons") 
		else:
			icon = load(IconPath)

class toolbarGodotTool extends toolbarEmptyElement:
	
	
	# Those numbers are offsets indexes from each other cuz 
	# Editor nodes are getting reparented to different place (my sideToolbar)
	# so the indexes of those buttons change
	var _godotToolsIndxOffsetTable : Dictionary[godotBuiltinTools,int] = {
		
		godotBuiltinTools.Selection : 0,
		godotBuiltinTools.Move : 1,
		godotBuiltinTools.Rotate : 1,
		godotBuiltinTools.Scale : 1,
		godotBuiltinTools.Ruler : 7
	}
	
	var toolIndex : int
	var godotToolType : godotBuiltinTools
	
	func _init(id : godotBuiltinTools) -> void:
		toolIndex = _godotToolsIndxOffsetTable[id]
		godotToolType = id

var toolbarElements : Array[toolbarEmptyElement] = [
	toolbarGodotTool.new(godotBuiltinTools.Selection),
	toolbarTool.new("Cursor","uid://hb44vi08fta4"),
	toolbarEmptyElement.new(),
	toolbarGodotTool.new(godotBuiltinTools.Move),
	toolbarGodotTool.new(godotBuiltinTools.Scale),
	toolbarGodotTool.new(godotBuiltinTools.Rotate),
	toolbarEmptyElement.new(),
	toolbarTool.new("Annotate","@Edit"),
	toolbarGodotTool.new(godotBuiltinTools.Ruler),
	toolbarEmptyElement.new(),
	toolbarTool.new("Add Shape","@BoxMesh")
]

func _init(plugin : MBP) -> void:
	
	godotMenuToolbar = MBP.spatialEditorToolbar.get_child(0)
	
	#TODO Replace my workaround with intended plugin.scene_changed signal
	#	once something will be done with https://github.com/godotengine/godot/issues/97427
	
	_dirLightEditorButton = godotMenuToolbar.get_child(16)
	_worldEnvEditorButton = godotMenuToolbar.get_child(17)
	_lightEnvEditorButton = godotMenuToolbar.get_child(18)
	_lightEnvEditorVSep = godotMenuToolbar.get_child(19)
	
	_worldEnvEditorButton.visible = false
	_dirLightEditorButton.visible = false
	_lightEnvEditorButton.visible = false
	_lightEnvEditorVSep.visible = false
	
	setupSideToolbar()
	
	# Those 3 lines are for hiding two VSeparation nodes from top Godot spatial menu
	# and one button for showing list of selectable nodes on clicked position
	# which in my opinion is useless so I'm hiding it
	# TODO You should probably add setting for people that actually consider it useful
	godotMenuToolbar.get_child(0).hide()
	godotMenuToolbar.get_child(1).hide()
	godotMenuToolbar.get_child(2).hide()

func setupSideToolbar()->void:
	toolbarButtonGroup = ButtonGroup.new()
	
	for toolbarElement : toolbarEmptyElement in toolbarElements:
			if toolbarElement is toolbarTool:
				var button := Button.new()
				button.icon = toolbarElement.icon
				button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				button.custom_minimum_size = Vector2i(32,28)
				button.theme_type_variation = "FlatButton"
				button.tooltip_text = toolbarElement.title
				button.toggle_mode = true
				button.button_group = toolbarButtonGroup
				MBP.sideToolbar.add_child(button)
			elif toolbarElement is toolbarGodotTool:
				var godotToolButton : Button = godotMenuToolbar.get_child(toolbarElement.toolIndex)
				godotToolButton.button_group = toolbarButtonGroup
				godotToolButton.reparent(MBP.sideToolbar)
			else:
				var separator := HSeparator.new()
				MBP.sideToolbar.add_child(separator)

## my plugin replacement for _ready since the regular one only works in EditorPlugin class
func _start()-> void:
	pass

## my plugin replacement for _process since the regular one only works in EditorPlugin class
func _update()->void:
	hideLightAndEnvButtonsIfNeeded()

## Called when the plugin is disabled from the list
func onPluginRemove()->void:
	godotMenuToolbar.get_child(0).show()
	godotMenuToolbar.get_child(1).show()
	godotMenuToolbar.get_child(2).show()
	
	_worldEnvEditorButton.show()
	_dirLightEditorButton.show()
	_lightEnvEditorButton.show()
	_lightEnvEditorVSep.show()
	
	var reparentedCount : int = 0
	for index in toolbarElements.size():
		var toolbarElement : toolbarEmptyElement = toolbarElements[index]
		if toolbarElement is toolbarGodotTool:
			var godotToolButton : Button = MBP.sideToolbar.get_child(index - reparentedCount)
			godotToolButton.reparent(godotMenuToolbar)
			reparentedCount += 1
			godotMenuToolbar.move_child(godotToolButton,godotToolsIndexTable[toolbarElement.godotToolType])
	
func hideLightAndEnvButtonsIfNeeded()->void:
	if Engine.get_physics_frames() % 5 == 0:
		_worldEnvEditorButton.visible = !_worldEnvEditorButton.disabled
		_dirLightEditorButton.visible = !_dirLightEditorButton.disabled
		_lightEnvEditorButton.visible = !_worldEnvEditorButton.disabled or !_dirLightEditorButton.disabled
		_lightEnvEditorVSep.visible = _lightEnvEditorButton.visible

## my plugin replacement for _input since the regular one only works in EditorPlugin class
func _receiveInput(event : InputEvent)->void:
	if event is InputEventKey:
		if event.keycode == sideToolbarToogleKey:
			if event.is_pressed() and isSideBarKeyJustPressed:
				isSideBarKeyJustPressed = false
				if MouseHoverEditor.isHovering:
					sideBarVisibility = !sideBarVisibility
					MBP.plugin.sideToolbarToogle(sideBarVisibility)
			elif event.is_released():
				isSideBarKeyJustPressed = true
