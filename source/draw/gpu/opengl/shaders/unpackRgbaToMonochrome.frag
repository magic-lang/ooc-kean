precision mediump float;
uniform sampler2D texture0;
uniform vec4 flip_texture0;
uniform int targetWidth;
in highp vec4 fragmentTextureCoordinate;
out float outColor;
void main() {
	int pixelIndex = int(float(targetWidth) * fragmentTextureCoordinate.z) % 4;
	outColor = SAMPLE(texture0, flip_texture0, fragmentTextureCoordinate)[pixelIndex];
}
