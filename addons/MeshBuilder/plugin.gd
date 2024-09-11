@tool
extends EditorPlugin

var instantiatedEditorDock : MeshBuilderManager
var _toolbar : HBoxContainer
var vertexGizPlugin_res := preload("res://addons/MeshBuilder/pluginFrontend/gizmos/VertexGizmoPlugin.gd")
var vertexGizmo_plugin = vertexGizPlugin_res.new()

func _enter_tree():
	# Creates gizmo to edit vertieces positions and etc
	add_node_3d_gizmo_plugin(vertexGizmo_plugin)
	
	# Creates this dock to change tools to edit mesh and etc
	instantiatedEditorDock = preload("res://addons/MeshBuilder/pluginFrontend/MeshBuilderDock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UR,instantiatedEditorDock)
	instantiatedEditorDock.vertexGizmo_plugin = vertexGizmo_plugin
	instantiatedEditorDock.connectSelectionChanged_toVertexPlugin()
	
	# Creates a toolbar to swtich selection modes which will be visible every time you select a mesh instance
	_toolbar = HBoxContainer.new()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _toolbar)
	
	# Loads placeholder icons from Godot to use make tools in dock easier to identify
	var meshEditIcons : Array[Texture2D] = [
		get_editor_interface().get_base_control().get_theme_icon("3D","EditorIcons")
	]
	
	# Sends placeholder icons into the dock so it can be used without errors
	instantiatedEditorDock.meshEditOptionsIcons = meshEditIcons
	# Calls a function from dock so it will load sended placeholder icons
	instantiatedEditorDock.loadIconsIntoMeshEditField()
	# Sends toolbar to dock so it can change tools depending on selection mode
	instantiatedEditorDock.selectionModeToolbar = _toolbar
	
	# Hides the toolbar so it won't be always visible 
	_toolbar.hide()
	
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
		_toolbar.add_child(selectMode_button)
		
		selectMode_button.custom_minimum_size = Vector2(30,30)
		selectModeButton_Callable = Callable(instantiatedEditorDock,"setSelectionMode")
		
		# adding into the callable info about button's id
		selectModeButton_Callable = selectModeButton_Callable.bindv([i])
		
		selectMode_button.connect("pressed",selectModeButton_Callable)


func _exit_tree():
	remove_control_from_docks(instantiatedEditorDock)
	remove_node_3d_gizmo_plugin(vertexGizmo_plugin)
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU,_toolbar)
	instantiatedEditorDock.free()
	_toolbar.free()
