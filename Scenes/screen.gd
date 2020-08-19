extends MeshInstance

var mat = get_surface_material(0)

export(Texture) var texture;

func _ready():
	#mat.set_shader_param("camera_texture", texture)
	pass

