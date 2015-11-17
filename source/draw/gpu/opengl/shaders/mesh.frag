#version 300 es
precision highp float;
uniform sampler2D texture0;
in vec2 fragmentTextureCoordinate;
out vec4 outColor;
void main() {
	outColor = texture(texture0, fragmentTextureCoordinate).rgba;
}
