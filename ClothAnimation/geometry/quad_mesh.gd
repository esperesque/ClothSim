extends MeshInstance3D

# Godot uses clockwise winding order

var v0:Vector3 # bottom-left
var v1:Vector3 # top-left
var v2:Vector3 # top-right
var v3:Vector3 # bottom-right
var mat:Material
var uv_tl:Vector2 # Top-left UV
var uv_tr:Vector2
var uv_br:Vector2 # Bottom-right UV
var uv_bl:Vector2

var tex = load("res://textures/bubbl_dog.jpg")

func _ready():
	mesh = ArrayMesh.new()
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	verts.append_array([v0, v1, v2, v0, v2, v3])
	uvs.append_array([uv_bl, uv_tl, uv_tr, uv_bl, uv_tr, uv_br])
	var vec1 = v3 - v0
	var vec2 = v1 - v0
	var norm = vec1.cross(vec2)
	norm = norm.normalized()
	normals.append_array([norm, norm, norm, norm, norm, norm])
	indices.append_array([0, 1, 2, 3, 4, 5])
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mat = StandardMaterial3D.new()
	#mat.albedo_color = Color.PALE_GREEN
	mat.albedo_texture = tex
	mesh.surface_set_material(0, mat)

func update():
	_ready()
	return
	
	mesh = ArrayMesh.new()
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	verts.append_array([v0, v1, v2, v0, v2, v3])
	uvs.append_array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
	var vec1 = v3 - v0
	var vec2 = v1 - v0
	var norm = vec1.cross(vec2)
	norm = norm.normalized()
	normals.append_array([norm, norm, norm, norm, norm, norm])
	indices.append_array([0, 1, 2, 3, 4, 5])
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mat = StandardMaterial3D.new()
	mat.albedo_color = Color.PALE_GREEN
	mesh.surface_set_material(0, mat)
