@tool
extends EditorPlugin

var meshBuilderLogo = preload("res://addons/MeshBuilder/MeshBuilderLogo.svg")

var meshBuilderEditor : MeshBuilderEditor
var spatialEditorToolbar : HFlowContainer
var toolbar : HBoxContainer

var turnOnBuilderButton : Button
var meshSelectionModeButton : OptionButton
var spatialOptions : MenuButton
var exitBuilderModeButton : Button
var editorTitleBar : HBoxContainer

func _enter_tree():
	# Creates this dock to change tools to edit mesh and etc
	meshBuilderEditor = preload("res://addons/MeshBuilder/pluginFrontend/MeshBuilderDock.tscn").instantiate()
	#add_control_to_dock(DOCK_SLOT_LEFT_UR,meshBuilderEditor)
	
	# Creates a toolbar to swtich selection modes which will be visible every time you select a mesh instance
	var toolbar_placeholder := Button.new()
	toolbar_placeholder.size = Vector2i.ZERO
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, toolbar_placeholder)
	spatialEditorToolbar = toolbar_placeholder.get_parent().get_parent().get_parent()
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, toolbar_placeholder)
	toolbar_placeholder.queue_free()
	toolbar = HBoxContainer.new()
	toolbar.name = "meshBuilderToolbar"
	spatialEditorToolbar.get_parent().add_child(toolbar)
	toolbar.hide()
	
	# Creates a button that allows to turn mesh builder edit mode when mesh instance 3D is selected
	var viewport = EditorInterface.get_editor_viewport_3d(0)
	var vboxParent : VBoxContainer = viewport.get_parent().get_parent().get_child(1).get_child(0)
	spatialOptions = vboxParent.get_child(0)
	
	turnOnBuilderButton = Button.new()
	turnOnBuilderButton.pressed.connect(meshBuilderEditor.turnOnMeshEditMode)
	turnOnBuilderButton.name = "BuilderButton"
	turnOnBuilderButton.text = "edit mesh"
	turnOnBuilderButton.icon = meshBuilderLogo
	turnOnBuilderButton.expand_icon = true
	
	vboxParent.add_child(turnOnBuilderButton)
	
	var styleBox := StyleBoxFlat.new()
	styleBox.bg_color = Color(0,0,0,0.3137)
	styleBox.set_corner_radius_all(8)
	styleBox.content_margin_left = 12
	styleBox.content_margin_top = 8
	styleBox.content_margin_right = 12
	styleBox.content_margin_bottom = 8
	
	turnOnBuilderButton.add_theme_stylebox_override("focus",styleBox)
	turnOnBuilderButton.add_theme_stylebox_override("disabled_mirrored",styleBox)
	turnOnBuilderButton.add_theme_stylebox_override("disabled",styleBox)
	turnOnBuilderButton.add_theme_stylebox_override("hover_pressed_mirrored",styleBox)
	turnOnBuilderButton.add_theme_stylebox_override("hover_pressed",styleBox)
	turnOnBuilderButton.add_theme_stylebox_override("hove_mirrored",styleBox)
	turnOnBuilderButton.add_theme_stylebox_override("hover",styleBox)
	turnOnBuilderButton.add_theme_stylebox_override("pressed_mirrored",styleBox)
	turnOnBuilderButton.add_theme_stylebox_override("pressed",styleBox)
	turnOnBuilderButton.add_theme_stylebox_override("normal_mirrored",styleBox)
	turnOnBuilderButton.add_theme_stylebox_override("normal",styleBox)
	
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
	
	meshSelectionModeButton.add_theme_stylebox_override("focus",styleBox)
	meshSelectionModeButton.add_theme_stylebox_override("disabled_mirrored",styleBox)
	meshSelectionModeButton.add_theme_stylebox_override("disabled",styleBox)
	meshSelectionModeButton.add_theme_stylebox_override("hover_pressed_mirrored",styleBox)
	meshSelectionModeButton.add_theme_stylebox_override("hover_pressed",styleBox)
	meshSelectionModeButton.add_theme_stylebox_override("hove_mirrored",styleBox)
	meshSelectionModeButton.add_theme_stylebox_override("hover",styleBox)
	meshSelectionModeButton.add_theme_stylebox_override("pressed_mirrored",styleBox)
	meshSelectionModeButton.add_theme_stylebox_override("pressed",styleBox)
	meshSelectionModeButton.add_theme_stylebox_override("normal_mirrored",styleBox)
	meshSelectionModeButton.add_theme_stylebox_override("normal",styleBox)
	
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
	meshBuilderEditor.meshEditOptionsIcons = meshEditIcons
	# Calls a function from dock so it will load sended placeholder icons
	#meshBuilderEditor.loadIconsIntoMeshEditField()
	# Sends toolbar to dock so it can change tools depending on selection mode
	meshBuilderEditor.selectionModeToolbar = toolbar
	meshBuilderEditor.spatialEditorToolbar = spatialEditorToolbar
	meshBuilderEditor.turnOnBuilderButton = turnOnBuilderButton
	meshBuilderEditor.exitMeshBuilderButton = exitBuilderModeButton
	meshBuilderEditor.meshSelectionModeButton = meshSelectionModeButton
	meshBuilderEditor.editorTitleBar = editorTitleBar
	meshBuilderEditor.spatialOptions = spatialOptions
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


func getMainScreenButtons()->HBoxContainer:
	var ctrl : Control = EditorInterface.get_base_control()
	ctrl = ctrl.get_child(0).get_child(0).get_child(2)
	return ctrl

func _exit_tree():
	#remove_control_from_docks(meshBuilderEditor)
	exitBuilderModeButton.queue_free()
	meshBuilderEditor.turnOffMeshEditMode()
	meshBuilderEditor.spatialGizmoSnapPoint.queue_free()
	meshBuilderEditor.queue_free()
	if is_instance_valid(toolbar):
		remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU,toolbar)
		toolbar.queue_free()
	turnOnBuilderButton.queue_free()
