shader_type canvas_item;

uniform sampler2D maskTex: source_color, filter_nearest;
uniform sampler2D cloudsTex: source_color, filter_nearest, repeat_enable;

uniform float cloudSpeed = .08;

void fragment() {
	vec4 window = texture(TEXTURE, UV);
	vec4 mask = texture(maskTex, UV);
	
	vec2 cloudUV = UV;
	cloudUV.x += TIME * cloudSpeed + SCREEN_UV.x;
	vec4 clouds = texture(cloudsTex, cloudUV);
	
	COLOR = mix(window, mix(window, clouds, clouds.a), mask.a);
}
