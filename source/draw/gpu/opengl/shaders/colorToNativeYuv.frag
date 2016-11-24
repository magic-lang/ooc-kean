#version 300 es
#extension GL_EXT_YUV_target : enable
precision highp float;
uniform vec4 color;
layout (yuv) out vec4 outColor;
void main() {
	outColor = vec4(color.r, color.g, color.b, 1.0f);
}
