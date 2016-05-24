#version 300 es
precision mediump float;
uniform mat4 transform;
uniform float xOffset;
uniform float texelOffset;
layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec2 textureCoordinate;
out vec2 fragmentTextureCoordinate[4];
void main() {
	fragmentTextureCoordinate[0] = textureCoordinate + vec2(-xOffset, 0);
	fragmentTextureCoordinate[1] = textureCoordinate + vec2(texelOffset - xOffset, 0);
	fragmentTextureCoordinate[2] = textureCoordinate + vec2(2.0f * texelOffset - xOffset, 0);
	fragmentTextureCoordinate[3] = textureCoordinate + vec2(3.0f * texelOffset - xOffset, 0);
	gl_Position = transform * vec4(vertexPosition, 1);
}
