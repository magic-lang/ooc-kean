#version 300 es
precision highp float;
uniform sampler2D texture0;
in vec2 fragmentTextureCoordinate;
out vec4 outColor;
vec4 RgbaToYuva(vec4 t) {
	mat4 matrix = mat4(0.299f, -0.168736f, 0.5f, 0.0f,
		0.587f, -0.331264f, -0.418688f, 0.0f,
		0.114f, 0.5f, -0.081312f, 0.0f,
		0.0f, 0.0f, 0.0f, 1.0f);
	return matrix * t;
}
void main() {
	outColor = (RgbaToYuva(texture(texture0, fragmentTextureCoordinate)) + vec4(0.0f, 0.5f, 0.5f, 0.0f)).gbaa;
}
