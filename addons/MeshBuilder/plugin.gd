@tool
extends EditorPlugin

## CLASS DEFINITIONS:

const MBP = preload("uid://c0n3wfy7l2xwm")

const MeshBuilderEditor = preload("uid://b3pwlm0cb24y")
const MBHandler = preload("uid://hivshk24w1n5")
const MouseHoveEditor = preload("uid://bsre3ybg4sjgs")

var meshBuilderEditor : MeshBuilderEditor

var meshBuilderHandler : MBHandler
var mouseHoverEditor : MouseHoveEditor


static var spatialEditorToolbar : HFlowContainer
static var toolbar : HBoxContainer

static var turnOnBuilderButton : Button
static var meshSelectionModeButton : OptionButton
static var spatialOptions : MenuButton
static var exitBuilderModeButton : Button
static var editorTitleBar : HBoxContainer

var sideToolbarParent : Control
static var sideToolbar : VBoxContainer

static var plugin : MBP

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

func createSideToolbar()->Control:
	var scrollContainer := ScrollContainer.new()
	sideToolbar = VBoxContainer.new()
	
	#marginContainer.add_theme_constant_override("margin_top", 2)
	#marginContainer.add_theme_constant_override("margin_left", 5)
	#marginContainer.add_theme_constant_override("margin_bottom", 2)
	#marginContainer.add_theme_constant_override("margin_right", 5)
	
	#marginContainer.size.x = 44
	scrollContainer.size.x = 32
	
	scrollContainer.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	#marginContainer.add_child(scrollContainer)
	scrollContainer.add_child(sideToolbar)
	
	scrollContainer.hide()
	
	return scrollContainer

func sideToolbarToogle(state : bool)->void:
	sideToolbarParent.visible = state

func _enter_tree():
	plugin = self
	name = "MBP - Mesh Builder Plugin"
	# Creates this dock to change tools to edit mesh and etc
	
	sideToolbarParent = createSideToolbar()
	
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_LEFT,sideToolbarParent)
	
	# Creates a toolbar to swtich selection modes which will be visible every time you select a mesh instance
	var toolbar_placeholder := Button.new()
	toolbar_placeholder.size = Vector2i.ZERO
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, toolbar_placeholder)
	spatialEditorToolbar = toolbar_placeholder.get_parent().get_parent().get_parent()
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, toolbar_placeholder)
	toolbar_placeholder.queue_free()
	toolbar = HBoxContainer.new()
	toolbar.name = "meshEditModeToolbar"
	spatialEditorToolbar.get_parent().add_child(toolbar)
	toolbar.hide()
	
	
	
	meshBuilderEditor = MeshBuilderEditor.new()
	mouseHoverEditor = MouseHoveEditor.new(self)
	meshBuilderHandler = MBHandler.new(self)
	
	
	
	# Creates a button that allows to turn mesh builder edit mode when mesh instance 3D is selected
	var viewport := EditorInterface.get_editor_viewport_3d(0)
	var vboxParent : VBoxContainer = viewport.get_parent().get_parent().get_child(1).get_child(0)
	spatialOptions = vboxParent.get_child(0)
	
	turnOnBuilderButton = Button.new()
	turnOnBuilderButton.pressed.connect(meshBuilderEditor.turnOnMeshEditMode)
	turnOnBuilderButton.name = "BuilderButton"
	turnOnBuilderButton.text = "edit mesh"
	turnOnBuilderButton.icon = load("uid://wsv0wfin21k6")
	turnOnBuilderButton.expand_icon = true
	
	vboxParent.add_child(turnOnBuilderButton)
	
	_copy_over_stylebox_overrides(spatialOptions,turnOnBuilderButton)
	
	turnOnBuilderButton.hide()
	
	meshSelectionModeButton = OptionButton.new()
	var meshSelectionModePopup := meshSelectionModeButton.get_popup()
	meshSelectionModePopup.id_pressed.connect(meshBuilderEditor.meshSelectionModeChanged)
	meshSelectionModeButton.name = "meshSelectionModeButton"
	
	for keyIndex in MeshBuilderEditor.meshEditModes.size():
		if keyIndex == 0:
			continue
		meshSelectionModePopup.add_item(str(MeshBuilderEditor.meshEditModes.keys()[keyIndex]).replace("_"," "),keyIndex)
	
	# -1 because first keyname "off" is ignored
	meshSelectionModeButton.select(MeshBuilderEditor.meshEditModes.edit_mode - 1)
	
	_copy_over_stylebox_overrides(spatialOptions,meshSelectionModeButton)
	
	vboxParent.add_child(meshSelectionModeButton)
	
	meshSelectionModeButton.hide()
	
	exitBuilderModeButton = Button.new()
	exitBuilderModeButton.pressed.connect(meshBuilderEditor.turnOffMeshEditMode)
	editorTitleBar = getMainScreenButtons()
	editorTitleBar.add_child(exitBuilderModeButton)
	exitBuilderModeButton.hide()
	exitBuilderModeButton.name = "exitMeshBuilder"
	exitBuilderModeButton.text = "Exit Mesh Builder"
	exitBuilderModeButton.icon = EditorInterface.get_editor_theme().get_icon("GuiClose", "EditorIcons")
	exitBuilderModeButton.theme_type_variation = "MainScreenButton"
	
	# Loads placeholder icons from Godot to use make tools in dock easier to identify
	var meshEditIcons : Array[Texture2D] = [
		get_editor_interface().get_base_control().get_theme_icon("3D","EditorIcons")
	]
	
	# Sends placeholder icons into the dock so it can be used without errors
	#meshBuilderEditor.meshEditOptionsIcons = meshEditIcons
	# Calls a function from dock so it will load sended placeholder icons
	#meshBuilderEditor.loadIconsIntoMeshEditField()
	meshBuilderEditor.spatialGizmoSnapPoint = MeshInstance3D.new()
	
	# Creates a group which will make sure that only one selection mode can turned on at a time.
	var selectModeButtons := ButtonGroup.new()
	
	# creates array of icons to selection modes
	var selectModeButtonIcons : Array[Texture2D] = [
		get_editor_interface().get_base_control().get_theme_icon("CurveEdit","EditorIcons"),
		get_editor_interface().get_base_control().get_theme_icon("Curve3D","EditorIcons"),
		get_editor_interface().get_base_control().get_theme_icon("Object","EditorIcons")
	]
	# creates array of texts to selection modes
	var selectModeButtonTooltips : Array[String] = [
		"select vertex mode",
		"select edge mode",
		"select face mode"
	]
	
	# temporar variables to create buttons to switch selection modes
	var selectMode_button : Button
	var selectModeButton_Callable : Callable
	
	# loop to automaticly configure 4 buttons to switch selection modes
	for i in selectModeButtonTooltips.size():
		selectMode_button = Button.new()
		selectMode_button.toggle_mode = true
		selectMode_button.flat = true
		selectMode_button.icon = selectModeButtonIcons[i]
		selectMode_button.tooltip_text = selectModeButtonTooltips[i]
		selectMode_button.set_button_group(selectModeButtons)
		
		# adds button to a selection mode toolbar
		toolbar.add_child(selectMode_button)
		
		selectMode_button.custom_minimum_size = Vector2(30,30)
		selectModeButton_Callable = Callable(meshBuilderEditor,"setMeshSelectionMode")
		
		# adding into the callable info about button's id
		selectModeButton_Callable = selectModeButton_Callable.bindv([i])
		
		selectMode_button.pressed.connect(selectModeButton_Callable)

func _input(event: InputEvent) -> void:
	# Prevents addon from working while game instance is running
	if !Engine.is_editor_hint():
		return
	mouseHoverEditor._receiveInput(event)
	meshBuilderHandler._receiveInput(event)
	meshBuilderEditor._receiveInput(event)

func _process(delta: float) -> void:
	# Prevents addon from working while game instance is running
	if !Engine.is_editor_hint():
		return
	
	meshBuilderEditor._update()
	meshBuilderHandler._update()

func _ready() -> void:
	# Prevents addon from working while game instance is running
	if !Engine.is_editor_hint():
		return
	
	meshBuilderEditor._start()
	meshBuilderHandler._start()

## This function returs the HboxContainer that is the parent of buttons used to switch main Godot editor 
##  like the 2D, 3D, Script, Game, Assetlib buttons
func getMainScreenButtons()->HBoxContainer:
	var ctrl : Control = EditorInterface.get_base_control()
	ctrl = ctrl.get_child(0).get_child(0).get_child(2)
	return ctrl

#region Edit Mesh essential [for later]
func _handles(object: Object) -> bool:
	return object is MeshInstance3D

#Prevents from selecting nodes when mesh builder mode is activated
#requires _handles function to work
func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if meshBuilderEditor.meshEditMode == meshBuilderEditor.meshEditModes.off:
		return EditorPlugin.AFTER_GUI_INPUT_PASS
	if event is InputEventMouseButton:
		if event.button_index == 1:
			return EditorPlugin.AFTER_GUI_INPUT_CUSTOM
	
	return EditorPlugin.AFTER_GUI_INPUT_PASS
#endregion

# Plugin cleanup
func _exit_tree():
	#remove_control_from_docks(meshBuilderEditor)
	exitBuilderModeButton.queue_free()
	meshBuilderEditor.onPluginRemove()
	meshBuilderEditor.queue_free()
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, sideToolbarParent)
	meshBuilderHandler.onPluginRemove()
	meshBuilderHandler.queue_free()
	sideToolbarParent.queue_free()
	mouseHoverEditor.queue_free()
	if is_instance_valid(toolbar):
		toolbar.queue_free()
	turnOnBuilderButton.queue_free()
	
