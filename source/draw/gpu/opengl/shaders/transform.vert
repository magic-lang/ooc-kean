#version 300 es
precision highp float;
uniform mat4 transform;
uniform mat4 textureTransform;
layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec2 textureCoordinate;
out vec2 fragmentTextureCoordinate;
void main() {
	vec4 position = vec4(vertexPosition, 1);
	vec4 transformedPosition = transform * position;
	vec4 texCoord = (textureTransform * vec4(textureCoordinate, 1, 1));
	fragmentTextureCoordinate = texCoord.xy;
	gl_Position = transformedPosition;
}
