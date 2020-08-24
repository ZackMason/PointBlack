shader_type spatial;

uniform sampler2D ground_texture;
uniform float scaling = 1.0f;

varying vec3 world_pos;

void vertex()
{
	world_pos = (WORLD_MATRIX * vec4(VERTEX, 1.0f)).xyz * scaling;
}

void fragment()
{
	vec4 color = texture(ground_texture, world_pos.xz);
	ALBEDO = color.rgb;
	METALLIC = 0.0f;
	ROUGHNESS = 0.8f;	
}

