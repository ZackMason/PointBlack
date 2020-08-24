shader_type spatial;
render_mode unshaded, blend_mix;

uniform float particle_power = 6.0;
uniform bool circle = false;

void vertex()
{
	//make billboard
	mat4 mat_world = mat4(normalize(CAMERA_MATRIX[0])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[1])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[2])*length(WORLD_MATRIX[2]),WORLD_MATRIX[3]);
	//rotate by rotation
	mat_world = mat_world * mat4( vec4(cos(INSTANCE_CUSTOM.x),-sin(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0, 1.0));
	//set modelview
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat_world;
}

void fragment()
{
	float d = 1.0-length(UV.xy - 0.5);
	d = pow(d,particle_power);
	if (!circle)
	{
		d = 1.0;
	}
	ALBEDO = pow(COLOR.rgb * vec3(2.0), vec3(2.2) * d);
	ALPHA = d;
}