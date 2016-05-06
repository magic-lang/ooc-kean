precision highp float;
uniform sampler2D texture0;
in vec2 fragmentTextureCoordinate;
out vec4 outColor;
void main() {
	float colorSample = texture(texture0, fragmentTextureCoordinate).r;
	outColor = vec4(colorSample, colorSample, colorSample, 1.0f);
}
