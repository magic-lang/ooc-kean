#version 300 es
#extension GL_EXT_YUV_target : enable
precision mediump float;
uniform __samplerExternal2DY2YEXT texture0;
in highp vec2 fragmentTextureCoordinate;
out vec2 outColor;
void main() {
	float uSample = texture(texture0, fragmentTextureCoordinate).g;
	float vSample = texture(texture0, fragmentTextureCoordinate).b;
	outColor = vec2(uSample, vSample);
}
