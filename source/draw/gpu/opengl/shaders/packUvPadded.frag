precision mediump float;
uniform sampler2D texture0;
uniform float rowUnit;
in highp vec2 fragmentTextureCoordinate[2];
out vec4 outColor;
void main() {
	vec2 shiftedCoor = vec2(fragmentTextureCoordinate[0].x, fragmentTextureCoordinate[0].y);
	if (shiftedCoor.x < 0.0) {
		shiftedCoor = vec2(1.0 + shiftedCoor.x, shiftedCoor.y - rowUnit);
	}
	vec2 rg = texture(texture0, shiftedCoor).rg;
	shiftedCoor = vec2(fragmentTextureCoordinate[1].x, fragmentTextureCoordinate[1].y);
	if (shiftedCoor.x < 0.0) {
		shiftedCoor = vec2(1.0 + shiftedCoor.x, shiftedCoor.y - rowUnit);
	}
	vec2 ba = texture(texture0, shiftedCoor).rg;
	outColor = vec4(rg.x, rg.y, ba.x, ba.y);
}
