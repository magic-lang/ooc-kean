#version 300 es
#extension GL_EXT_YUV_target : enable
precision mediump float;
uniform sampler2D texture0;
uniform sampler2D texture1;
in highp vec2 fragmentTextureCoordinate;
layout (yuv) out vec4 outColor;
void main() {
	float ySample = texture(texture0, fragmentTextureCoordinate).r;
	vec2 uvSample = texture(texture1, fragmentTextureCoordinate).rg;
	outColor = vec4(ySample, uvSample.r, uvSample.g, 1.0f);
}
