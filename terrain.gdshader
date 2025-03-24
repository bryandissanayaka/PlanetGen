shader_type spatial;
render_mode world_vertex_coords;

uniform float specular = 0.8;
uniform float roughness = 0.8;
uniform float radius = 10.0; // ADD PASSING THIS FROM PLANET.GD
uniform float height = 4.0; // THIS ONE TOO
uniform sampler2D gradient: repeat_disable;
varying vec4 world_vertex;

void vertex() {
	world_vertex = inverse(MODEL_MATRIX) * vec4(VERTEX, 1.0);
}

void fragment() {
	SPECULAR = specular;
	ROUGHNESS = roughness;
	
	float color_uv = (length(world_vertex.xyz) - radius) / height;
	ALBEDO = texture(gradient, vec2(color_uv, 0.0)).rgb;
}