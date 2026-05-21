shader_type spatial;
render_mode specular_toon;

uniform sampler2D noise;
uniform float heightScale;
uniform sampler2D normalmap;
varying vec2 tex_pos;

void vertex() {
	tex_pos = VERTEX.xz / 2. + .5;
	float height = texture(noise, VERTEX.xz /2. + .5).r * heightScale;
	VERTEX.y += height;
}

void fragment() {
	RIM = .2;
	METALLIC = 0.;
	ROUGHNESS = .01;
	NORMAL = texture(normalmap, tex_pos).xyz;
	ALBEDO = vec3(.1, .3, .5);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
