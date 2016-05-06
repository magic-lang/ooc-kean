precision mediump float;
uniform sampler2D texture0;
uniform vec4 flip_texture0;
in highp vec4 fragmentTextureCoordinate;
out vec4 outColor;
void main() {
	vec2 rg = SAMPLE(texture0, flip_texture0, fragmentTextureCoordinate.xy).rg;
	vec2 ba = SAMPLE(texture0, flip_texture0, fragmentTextureCoordinate.zw).rg;
	outColor = vec4(rg.x, rg.y, ba.x, ba.y);
}
