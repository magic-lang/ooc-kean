#version 300 es
precision mediump float;
uniform sampler2D texture0;
in highp vec2 fragmentTextureCoordinate[2];
out vec4 outColor;
void main() {
	vec2 rg = texture(texture0, fragmentTextureCoordinate[0]).rg;
	vec2 ba = texture(texture0, fragmentTextureCoordinate[1]).rg;
	outColor = vec4(rg.x, rg.y, ba.x, ba.y);
}
