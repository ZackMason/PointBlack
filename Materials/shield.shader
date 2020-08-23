shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_alpha_prepass;

uniform vec4 color : hint_color;
uniform vec4 highlight_color : hint_color;
uniform float fresnel_power;
uniform float hex_power;
uniform float highlight_dist;
uniform float highlight_power;

varying vec3 world_pos;
varying mat4 CAMERA;

void vertex()
{
	CAMERA = CAMERA_MATRIX;
	world_pos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float HexDist(vec2 p) {
	p = abs(p);
    
    float c = dot(p, normalize(vec2(1,1.73)));
    c = max(c, p.x);
    
    return c;
}

vec4 HexCoords(vec2 uv) {
	vec2 r = vec2(1, 1.73);
    vec2 h = r*.5;
    
    vec2 a = mod(uv, r)-h;
    vec2 b = mod(uv-h, r)-h;
    
    vec2 gv = dot(a, a) < dot(b,b) ? a : b;
    
    float x = atan(gv.x, gv.y);
    float y = .5-HexDist(gv);
    vec2 id = uv-gv;
    return vec4(x, y, id.x,id.y);
}

void fragment()
{
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 world = CAMERA * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 wp = world.xyz / world.w;
	float dist = distance(wp, world_pos);
	
	float intersection_highlight = 1.0-pow(smoothstep(pow(dist,1.0), 0., highlight_dist),highlight_power);
	
	vec3 n = normalize(VERTEX);
	float phi = atan(n.z,n.x);
	float theta = asin(n.y);
	vec2 uv = vec2(1.0-(phi+3.14159)/(2.0*3.14159), (theta+3.14159/2.0)/3.14159);
	
	float hex = pow(1.0-HexCoords(UV*50.).y, hex_power) / 3.0;
	
	float scan_line = mod((uv.y+ TIME/2.0) ,1.0);
	
	ALPHA = 
	clamp(pow(fresnel, fresnel_power) + intersection_highlight + hex * scan_line, 0.0, 1.0);
//	pow(step(dist, 2.0), 8.0);
	 //pow(clamp(distance(wp, world_pos) / 2.0, 0.0, 1.0), 8.0);
	ALBEDO = vec3(clamp(1.0 - dist / 1.0, 0.0, 1.0)) * 20.0;
	ALBEDO = vec3(0.7,0.7,0.9999) * fresnel * fresnel;
	ALBEDO = mix(pow(fresnel, fresnel_power) * color.rgb, (scan_line*hex + intersection_highlight) * highlight_color.rgb, 0.5) * 2.0;
	//ALBEDO = scan_line * vec3(1.);
	//ALPHA = 1.0;
	
}