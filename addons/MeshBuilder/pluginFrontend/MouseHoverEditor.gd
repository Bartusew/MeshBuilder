@tool
extends Node

## MBP stands for Mesh-Builder-Plugin
const MBP = preload("uid://c0n3wfy7l2xwm")
const MouseHoverEditor = preload("uid://bsre3ybg4sjgs")

## This class is used to check whether or not cursor is hovering over any 3D viewport
##  if the 3D viewport is hidden this class automatically will send signal
##  as if cursor weren't hovering over the viewport anymore

static var mouseHoverEditor : MouseHoverEditor

## state whether mouse is hovering over the viewport or not
static var isHovering : bool
## state whether or not editor is currently running in 3D mode
static var isIn3DMode : bool
var _wasHovering : bool = false

var _mousePos : Vector2i
var _viewRect : Rect2

var _viewportContainer : SubViewportContainer 

## Called once mouse enters 3D viewport's rect
signal mouseEntered 
## Called once mouse extis 3D viewport's rect
signal mouseExited

## my plugin replacement for _input since the regular one only works in EditorPlugin class
func _receiveInput(event : InputEvent)->void:
	if event is InputEventMouseMotion:
		_mousePos = event.global_position
		self._checkHover()

func _init(plugin : MBP) -> void:
	# Prevents addon from working inside the game
	if !Engine.is_editor_hint():
		return
	
	if mouseHoverEditor != null:
		push_error("Instance of [MouseHoverEditor] already exists!")
		self.queue_free()
	
	mouseHoverEditor = self
	
	plugin.main_screen_changed.connect(modeStateChanged)
	
	_viewportContainer = EditorInterface.get_editor_viewport_3d(0).get_parent()
	_viewRect = _viewportContainer.get_global_rect()
	_viewportContainer.resized.connect(viewResized)

func _exit_tree() -> void:
	print("queue free instance of [MouseHoverEditor]")

func _checkHover()->void:
	isHovering = _viewRect.has_point(_mousePos) and self.isIn3DMode
	if isHovering != _wasHovering:
		_wasHovering = isHovering
		if isHovering:
			mouseEntered.emit()
		else:
			mouseExited.emit()

func viewResized()->void:
	_viewRect = _viewportContainer.get_global_rect()

func modeStateChanged(modeName : String)->void:
	await Engine.get_main_loop().process_frame
	self.isIn3DMode = modeName == "3D"
