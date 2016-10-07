#version 300 es
#extension GL_EXT_YUV_target : enable
precision mediump float;
uniform __samplerExternal2DY2YEXT texture0;
in highp vec2 fragmentTextureCoordinate;
out float outColor;
void main() {
	outColor = texture(texture0, fragmentTextureCoordinate).r;
}
