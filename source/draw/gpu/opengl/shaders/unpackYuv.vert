#version 300 es
precision highp float;
layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec2 textureCoordinate;
out vec2 fragmentTextureCoordinate;
void main() {
	fragmentTextureCoordinate = textureCoordinate;
	gl_Position = vec4(vertexPosition.x, -vertexPosition.y, 0, 1);
}
