extends EditorNode3DGizmoPlugin

var meshBuilderDock : MeshBuilderManager
var selectionMode : int
var texture = preload("res://icon.svg")

signal selectMode_changed(modeID : int)

func selectModeChanged(modeID : int):
	print("gizmoPlugin: ", modeID)
	selectionMode = modeID
	selectMode_changed.emit(modeID)

func _get_gizmo_name() -> String:
	return "VertexGizmo"

func _init():
	create_material("main", Color(1, 1, 1))
	create_handle_material("handles")

func _create_gizmo(for_node_3d):
	if for_node_3d is MeshBuilderNode:
		var newVertGizmo = VertexGizmo.new(for_node_3d,self)
		self.connect("selectMode_changed", Callable(newVertGizmo,"selectModeChanged"))
		return newVertGizmo
	return null
