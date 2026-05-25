shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
//uniform sampler2D screen_texture : repeat_disable, source_color;
uniform float circle_radius = .5;
uniform float distortion_strength = 0.02;

varying vec2 vUv;

void vertex() {
	vUv = UV;
}

void fragment() {
	vec2 dir = normalize(SCREEN_UV - vec2(.5));
	float distance_to_center = distance(vUv, vec2(.5));
	
	float effect_radius = circle_radius * 2.;
	float zone = smoothstep(effect_radius, circle_radius, distance_to_center);
	float force = zone/(distance_to_center + .01);
	
	vec2 deformed_uv = SCREEN_UV - dir * force * distortion_strength;

	if (distance_to_center < circle_radius) {
		ALBEDO = vec3(0);
	}
	else {
		vec3 color = textureLod(screen_texture, deformed_uv, 0.0).rgb;
		//color = color = pow(color, vec3(2.2));eare
		ALBEDO = color;
	}
}
