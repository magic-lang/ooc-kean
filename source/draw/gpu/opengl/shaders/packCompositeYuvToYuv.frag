#version 300 es
#extension GL_EXT_YUV_target : enable
precision mediump float;
uniform sampler2D y;
uniform sampler2D uv;
in highp vec2 fragmentTextureCoordinate;
layout (yuv) out vec4 outColor;
void main() {
	float ySample = texture(y, fragmentTextureCoordinate).r;
	vec2 uvSample = texture(uv, fragmentTextureCoordinate).rg;
	outColor = vec4(ySample, uvSample.r, uvSample.g, 1.0f);
}
