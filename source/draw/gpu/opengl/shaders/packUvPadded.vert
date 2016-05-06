precision mediump float;
uniform mat4 transform;
uniform float xOffset;
uniform float paddingOffset;
uniform float texelOffset;
layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec2 textureCoordinate;
out vec2 fragmentTextureCoordinate[2];
void main() {
	fragmentTextureCoordinate[0] = textureCoordinate + vec2(-xOffset - paddingOffset, 0);
	fragmentTextureCoordinate[1] = textureCoordinate + vec2(texelOffset - xOffset - paddingOffset, 0);
	gl_Position = transform * vec4(vertexPosition, 1);
}
