#version 300 es
precision highp float;
uniform sampler2D texture0;
uniform sampler2D texture1;
in vec2 fragmentTextureCoordinate;
out vec4 outColor;
vec4 YuvToRgba(vec4 t) {
	mat4 matrix = mat4(1, 1, 1, 0,
		-0.000001218894189, -0.344135678165337, 1.772000066073816, 0,
		1.401999588657340, -0.714136155581812, 0.000000406298063, 0,
		0, 0, 0, 1);
	return matrix * t;
}
void main() {
	float y = texture(texture0, fragmentTextureCoordinate).r;
	vec2 uv = texture(texture1, fragmentTextureCoordinate).rg;
	outColor = YuvToRgba(vec4(y, uv.r - 0.5f, uv.g - 0.5f, 1.0f));
}
