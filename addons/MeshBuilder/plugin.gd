@tool
extends EditorPlugin

var meshBuilderLogo = preload("res://addons/MeshBuilder/MeshBuilderLogo.svg")

var instantiatedEditorDock : MeshBuilderManager
var toolbar : HBoxContainer
var builderModeButton : Button

func _enter_tree():
	# Creates this dock to change tools to edit mesh and etc
	instantiatedEditorDock = preload("res://addons/MeshBuilder/pluginFrontend/MeshBuilderDock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UR,instantiatedEditorDock)
	
	# Creates a toolbar to swtich selection modes which will be visible every time you select a mesh instance
	toolbar = HBoxContainer.new()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, toolbar)
	
	# Creates a button that allows to turn mesh builder edit mode when mesh instance 3D is selected
	builderModeButton = Button.new()
	builderModeButton.name = "meshBuilderModeButton"
	builderModeButton.text = "edit mesh"
	builderModeButton.icon = meshBuilderLogo
	builderModeButton.expand_icon = true
	var viewport = EditorInterface.get_editor_viewport_3d(0)
	var vboxParent : VBoxContainer = viewport.get_parent().get_parent().get_child(1).get_child(0)
	vboxParent.add_child(builderModeButton)
	
	var styleBox := StyleBoxFlat.new()
	styleBox.bg_color = Color(0,0,0,0.3137)
	styleBox.set_corner_radius_all(8)
	styleBox.content_margin_left = 12
	styleBox.content_margin_top = 8
	styleBox.content_margin_right = 12
	styleBox.content_margin_bottom = 8
	
	builderModeButton.add_theme_stylebox_override("focus",styleBox)
	builderModeButton.add_theme_stylebox_override("disabled_mirrored",styleBox)
	builderModeButton.add_theme_stylebox_override("disabled",styleBox)
	builderModeButton.add_theme_stylebox_override("hover_pressed_mirrored",styleBox)
	builderModeButton.add_theme_stylebox_override("hover_pressed",styleBox)
	builderModeButton.add_theme_stylebox_override("hove_mirrored",styleBox)
	builderModeButton.add_theme_stylebox_override("hover",styleBox)
	builderModeButton.add_theme_stylebox_override("pressed_mirrored",styleBox)
	builderModeButton.add_theme_stylebox_override("pressed",styleBox)
	builderModeButton.add_theme_stylebox_override("normal_mirrored",styleBox)
	builderModeButton.add_theme_stylebox_override("normal",styleBox)
	
	builderModeButton.hide()
	
	
	# Loads placeholder icons from Godot to use make tools in dock easier to identify
	var meshEditIcons : Array[Texture2D] = [
		get_editor_interface().get_base_control().get_theme_icon("3D","EditorIcons")
	]
	
	# Sends placeholder icons into the dock so it can be used without errors
	instantiatedEditorDock.meshEditOptionsIcons = meshEditIcons
	# Calls a function from dock so it will load sended placeholder icons
	instantiatedEditorDock.loadIconsIntoMeshEditField()
	# Sends toolbar to dock so it can change tools depending on selection mode
	instantiatedEditorDock.selectionModeToolbar = toolbar
	instantiatedEditorDock.editMeshButton = builderModeButton
	
	# Hides the toolbar so it won't be always visible 
	toolbar.hide()
	
	# Creates a group which will make sure that only one selection mode can turned on at a time.
	var selectModeButtons := ButtonGroup.new()
	
	# creates array of icons to selection modes
	var selectModeButtonIcons : Array[Texture2D] = [
		get_editor_interface().get_base_control().get_theme_icon("MaterialPreviewCube","EditorIcons"),
		get_editor_interface().get_base_control().get_theme_icon("Object","EditorIcons"),
		get_editor_interface().get_base_control().get_theme_icon("Curve3D","EditorIcons"),
		get_editor_interface().get_base_control().get_theme_icon("CurveEdit","EditorIcons")
	]
	# creates array of texts to selection modes
	var selectModeButtonTooltips : Array[String] = [
		"select mesh mode",
		"select face mode",
		"select edge mode",
		"select vertex mode"
	]
	
	# temporar variables to create buttons to switch selection modes
	var selectMode_button : Button
	var selectModeButton_Callable : Callable
	
	# loop to automaticly configure 4 buttons to switch selection modes
	for i in 4:
		selectMode_button = Button.new()
		selectMode_button.toggle_mode = true
		selectMode_button.flat = true
		selectMode_button.icon = selectModeButtonIcons[i]
		selectMode_button.tooltip_text = selectModeButtonTooltips[i]
		selectMode_button.set_button_group(selectModeButtons)
		
		# adds button to a selection mode toolbar
		toolbar.add_child(selectMode_button)
		
		selectMode_button.custom_minimum_size = Vector2(30,30)
		selectModeButton_Callable = Callable(instantiatedEditorDock,"setMeshSelectionMode")
		
		# adding into the callable info about button's id
		selectModeButton_Callable = selectModeButton_Callable.bindv([i])
		
		selectMode_button.pressed.connect(selectModeButton_Callable)


func _exit_tree():
	remove_control_from_docks(instantiatedEditorDock)
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU,toolbar)
	instantiatedEditorDock.queue_free()
	toolbar.queue_free()
	builderModeButton.queue_free()
