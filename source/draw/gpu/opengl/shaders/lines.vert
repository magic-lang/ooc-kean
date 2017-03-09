#version 300 es
uniform mat4 transform;
layout(location = 0) in vec2 vertexPosition;
void main() {
	gl_Position = transform * vec4(vertexPosition.x, vertexPosition.y, 0.0f, 1.0f);
}
