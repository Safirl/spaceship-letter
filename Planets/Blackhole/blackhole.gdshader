shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D noise_texture;
uniform float noise_scale : hint_range(0.01, 10.) = 1.;
uniform float noise_speed = 1.;
uniform vec2 object_screen_uv;
uniform float circle_radius : hint_range(0.01, .5) = .4;
uniform float u_effect_radius : hint_range(0.01, .5) = 2.;
uniform float distortion_strength : hint_range(0.02, .05) = 0.02;

varying vec2 vUv;

void vertex() {
	vUv = UV;
}

void fragment() {
	
	vec2 dir = normalize(SCREEN_UV - object_screen_uv);
	float distance_to_center = distance(vUv, vec2(.5));
	
	//vec2 noise_uv = vUv * 000.1 + dir * TIME * noise_speed;
	vec2 noise_uv = vUv * noise_scale + dir + TIME * noise_speed; //* 1. + dir * TIME * noise_speed;
	float noise = texture(noise_texture, noise_uv).r;// cnoise(vec3(noise_uv.x, noise_uv.y, 1.));
	
	float effect_radius = circle_radius * 2.;
	float zone = smoothstep(effect_radius, circle_radius, distance_to_center);
	float force = zone/(distance_to_center + .01);
	
	vec2 deformed_uv = SCREEN_UV - dir * force * distortion_strength;// * noise;

	if (distance_to_center < circle_radius) {
		ALBEDO = vec3(0);
	}
	else {
		vec3 color = textureLod(screen_texture, deformed_uv, 0.0).rgb;
		//color = color = pow(color, vec3(2.2));eare
		ALBEDO = color;
		//ALBEDO = vec3(object_screen_uv.xy, 1.0);
	}
}
