precision mediump float;
uniform sampler2D texture0;
uniform vec4 flip_texture0;
uniform int targetWidth;
in highp vec4 fragmentTextureCoordinate;
out vec2 outColor;
void main() {
	int pixelIndex = int(float(targetWidth) * fragmentTextureCoordinate.z) % 2;
	vec4 texel = SAMPLE(texture0, flip_texture0, fragmentTextureCoordinate.xy);
	vec2 mask = vec2(float(1 - pixelIndex), float(pixelIndex));
	outColor = vec2(mask.x * texel.r + mask.y * texel.b, mask.x * texel.g + mask.y * texel.a);
}
