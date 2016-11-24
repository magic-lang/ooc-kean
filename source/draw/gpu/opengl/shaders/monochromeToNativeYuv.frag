#version 300 es
#extension GL_EXT_YUV_target : enable
precision mediump float;
uniform sampler2D texture0;
in highp vec2 fragmentTextureCoordinate;
layout (yuv) out vec4 outColor;
void main() {
	outColor = vec4(texture(texture0, fragmentTextureCoordinate).r, 0.5f, 0.5f, 1.0f);
}
