precision mediump float;
uniform sampler2D texture0;
uniform vec4 flip_texture0;
uniform int targetWidth;
uniform float rowUnit;
uniform float paddingOffset;
in highp vec4 fragmentTextureCoordinate;
out vec2 outColor;
void main() {
	vec2 shiftedCoor = vec2(fragmentTextureCoordinate.x + paddingOffset, fragmentTextureCoordinate.y);
	if (shiftedCoor.x > 1.0) {
		shiftedCoor = vec2(fract(shiftedCoor.x), shiftedCoor.y + rowUnit);
	}
	int pixelIndex = int(float(targetWidth) * shiftedCoor.x) % 2;
	vec4 texel = SAMPLE(texture0, flip_texture0, shiftedCoor.xy);
	vec2 mask = vec2(float(1 - pixelIndex), float(pixelIndex));
	outColor = vec2(mask.x * texel.r + mask.y * texel.b, mask.x * texel.g + mask.y * texel.a);
}
