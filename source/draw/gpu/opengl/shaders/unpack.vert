#version 300 es
precision mediump float;
uniform float startY;
uniform float scaleX;
uniform float scaleY;
uniform mat4 transform;
layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec2 textureCoordinate;
out vec4 fragmentTextureCoordinate;
void main() {
	fragmentTextureCoordinate = vec4(scaleX * textureCoordinate.x, startY + scaleY * textureCoordinate.y, textureCoordinate);
	gl_Position = transform * vec4(vertexPosition.x, -vertexPosition.y, 0, 1);
}
