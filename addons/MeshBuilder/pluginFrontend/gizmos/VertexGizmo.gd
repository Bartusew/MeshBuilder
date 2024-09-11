extends EditorNode3DGizmo
class_name VertexGizmo

var  builder : MeshBuilderNode
var gizmoPlugin : EditorNode3DGizmoPlugin

var selectionMode : int

var lines = PackedVector3Array()
var handles = PackedVector3Array()

var mainMat : StandardMaterial3D
var handleMat : StandardMaterial3D

func _get_gizmo_name() -> String:
	return "VertexGizmo"

func selectModeChanged(modeID : int):
	selectionMode = modeID
	_redraw()

func _init(buildNode : MeshBuilderNode, gizmoPlugin : EditorNode3DGizmoPlugin):
	builder = buildNode
	builder.connect("meshChanged", Callable(self, "meshChanged"))

func meshChanged(newMesh : Mesh):
	if newMesh == null:
		return
	print("newMesh: ",newMesh)
	
	var vertecies : PackedVector3Array = newMesh.get_faces()
	var arrMesh := ArrayMesh.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertecies
	arrMesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS,arrays)
	var sf := SurfaceTool.new()
	sf.create_from(arrMesh,0)
	sf.index()
	sf.commit(arrMesh)
	#print(ArrMesh.surface_get_arrays(0)[0].size())
	
	#print("newMesh arrays: ", newMesh.surface_get_arrays(0)[0])
	print("newMesh vertex count: ", arrMesh.surface_get_arrays(0)[0].size())
	handles = PackedVector3Array(
		[
			Vector3(-1, 1, 1)/2,
			Vector3(-1, 1, -1)/2,
			Vector3(1, 1, -1)/2,
			Vector3(1, 1, 1)/2,
			Vector3(-1, -1, 1)/2,
			Vector3(-1, -1, -1)/2,
			Vector3(1, -1, -1)/2,
			Vector3(1, -1, 1)/2
		]
	)

func _redraw() -> void:
	clear()
	
	print("vertex gizmo redraw")
	
	if builder.mesh == null or selectionMode != 3:
		return
	
#	lines.push_back(Vector3(0, 0, 0))
#	lines.push_back(Vector3(1, 1, 0))

#	handles.push_back(Vector3(-1, 1, 1)/2)
#	handles.push_back(Vector3(-1, 1, -1)/2)
#	handles.push_back(Vector3(1, 1, -1)/2)
#	handles.push_back(Vector3(1, 1, 1)/2)
#	handles.push_back(Vector3(-1, -1, 1)/2)
#	handles.push_back(Vector3(-1, -1, -1)/2)
#	handles.push_back(Vector3(1, -1, -1)/2)
#	handles.push_back(Vector3(1, -1, 1)/2)
	
	mainMat = get_plugin().get_material("main")
	handleMat = get_plugin().get_material("handles")
	
#	add_lines(lines, mainMat, false)
	add_handles(handles, handleMat, [])
#	_commit_handle(handles, false,false,true)

func _get_handle_value(id, secondary):
	print(id)

func _get_handle_name(id, secondary):
	pass
