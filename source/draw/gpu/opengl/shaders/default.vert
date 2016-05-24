#version 300 es
precision highp float;
layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec2 textureCoordinate;
out vec2 fragmentTextureCoordinate;
void main() {
	vec4 position = vec4(vertexPosition, 1);
	fragmentTextureCoordinate = textureCoordinate;
	gl_Position = position;
}
