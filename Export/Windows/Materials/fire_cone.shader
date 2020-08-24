shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_alpha_prepass;

uniform vec4 color_1 : hint_color;
uniform vec4 color_2 : hint_color;
uniform vec4 color_3 : hint_color;

uniform float fall_off_power = 1.0;
uniform float final_multi = 1.0;
uniform float fresnel_power = 1.0;
uniform float noise_power = 1.0;

uniform sampler2D noise_texture;

void vertex()
{
	VERTEX += NORMAL * abs(sin(TIME))/8.0;
}

vec2 samp(float d){
	return vec2(cos(d), sin(d));
}

void fragment()
{
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	fresnel = pow(fresnel, fresnel_power);
	
	vec2 uv = UV.xy - 0.5;
	float d1 = pow(mod(length(uv) + TIME,1.0), fall_off_power);
	float n1 = texture(noise_texture, UV.xy+vec2(0,-TIME)).r;
	float n2 = texture(noise_texture, UV.xy+vec2(0,-TIME/2.0)).r;
	float n3 = texture(noise_texture, -UV.xy+vec2(0,-TIME)).r;
	float n = n1 * n2 * n3;
	vec4 color = color_1;
	
	n *= texture(noise_texture, samp(d1)).r;
	n = n * noise_power;
	if (n > 0.66666)
	{
		color = color_3;
	}
	else if (n > 0.33333)
	{
		color = color_2;
	}
	ALBEDO = color.rgb * d1 * fresnel * final_multi;
//	ALBEDO = vec3(n);
	ALPHA = 1.0;
}