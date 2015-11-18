#version 300 es
precision mediump float;
uniform sampler2D texture0;
uniform int targetWidth;
in highp vec4 fragmentTextureCoordinate;
out float outColor;
void main() {
	int pixelIndex = int(float(targetWidth) * fragmentTextureCoordinate.z) % 4;
	outColor = texture(texture0, fragmentTextureCoordinate.xy)[pixelIndex];
}
