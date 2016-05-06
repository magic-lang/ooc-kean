precision mediump float;
uniform sampler2D texture0;
in highp vec2 fragmentTextureCoordinate[4];
out vec4 outColor;
void main() {
	float r = texture(texture0, fragmentTextureCoordinate[0]).x;
	float g = texture(texture0, fragmentTextureCoordinate[1]).x;
	float b = texture(texture0, fragmentTextureCoordinate[2]).x;
	float a = texture(texture0, fragmentTextureCoordinate[3]).x;
	outColor = vec4(r, g, b, a);
}
