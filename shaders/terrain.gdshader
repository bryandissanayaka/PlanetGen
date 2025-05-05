shader_type spatial;
render_mode world_vertex_coords;

uniform float specular = 0.8;
uniform float roughness = 0.8;
uniform float radius = 10.0;
uniform float height = 4.0;
uniform sampler2D gradient: repeat_disable;
uniform sampler2D climate_gradient: repeat_disable;
uniform float climate_strength = 0.5;
varying vec4 world_vertex;

void vertex() {
	world_vertex = inverse(MODEL_MATRIX) * vec4(VERTEX, 1.0);
}

void fragment() {
	SPECULAR = specular;
	ROUGHNESS = roughness;
    float alt_uv = (length(world_vertex.xyz) - radius) / height;
    vec3 base_color = texture(gradient, vec2(alt_uv, 0.0)).rgb;
    vec3 pos_n = normalize(world_vertex.xyz);
    float lat_factor = 1.0 - abs(pos_n.y);
    vec3 climate_color = texture(climate_gradient, vec2(lat_factor, 0.0)).rgb;
    ALBEDO = mix(base_color, climate_color, climate_strength);
}
