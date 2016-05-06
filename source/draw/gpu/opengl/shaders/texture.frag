precision highp float;
uniform sampler2D texture0;
uniform vec4 flip_texture0;
in vec2 fragmentTextureCoordinate;
out vec4 outColor;
void main() {
	outColor = SAMPLE(texture0, flip_texture0, fragmentTextureCoordinate).rgba;
}
