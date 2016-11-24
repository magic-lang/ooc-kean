#version 300 es
#extension GL_EXT_YUV_target : enable
precision highp float;
uniform vec4 color;
layout (yuv) out vec4 outColor;
void main() {
	outColor = vec4(1.0f, 0.5f, 0.5f, 1.0f);
}
