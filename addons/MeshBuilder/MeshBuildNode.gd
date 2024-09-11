@tool
@icon("res://addons/MeshBuilder/MeshBuilderLogo.svg")
extends MeshInstance3D
class_name MeshBuilderNode

signal meshChanged(newMesh : Mesh)

var oldMesh : Mesh

func _ready():
	pass

func _process(delta):
	if !Engine.is_editor_hint():
		return
	if mesh != oldMesh:
		oldMesh = mesh
		meshChanged.emit(mesh)
