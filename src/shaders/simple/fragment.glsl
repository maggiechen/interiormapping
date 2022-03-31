#version 330 core
out vec4 FragColor;
in vec3 Position;
in vec3 ObjectPos;
in vec2 TexCoord;
in vec3 Tangent;
in vec3 Normal;
uniform vec3 EyePos;
uniform samplerCube CubeMap;

uniform float RoomHeight;

// ASSUMPTIONS:
// We assume the pivot of the object is in the very center of the mesh.
// We assume the object's bottom is at y = 0

void main()
{
    vec3 bitangent = cross(Tangent, Normal);

	// TODO: why do we need to transpose?
    mat3 worldToTangent = transpose(mat3(bitangent, Tangent, Normal));

	// the vector going towards the interior surface from the entry position
    vec3 eye = -normalize(worldToTangent * (EyePos - Position));
	
	float RoomHeightInObjectSpace = RoomHeight * ObjectPos.y / Position.y;
	float yTop = ceil(Position.y/RoomHeight) * RoomHeightInObjectSpace;
	float yBottom = floor(Position.y/RoomHeight) * RoomHeightInObjectSpace;
	
	float yIntersectionT = min(
		yTop/eye.y-TexCoord.y/eye.y,
		yBottom/eye.y-TexCoord.y/eye.y);

	float parametricT = min(min(
		abs(1/eye.x) - TexCoord.x/eye.x,
		yIntersectionT),
		-2/eye.z); // assume the z component of the eye vector is in the positive z axis

	// need z=1.0 because the raycast starts from the entry position, which is not the origin
	// of the interior space, but 1 unit before it.
	vec3 intersectPoint = parametricT * eye + vec3(TexCoord.xy, 1.0);

	vec3 textureCoord = vec3(intersectPoint.x, (intersectPoint.y - yBottom)/RoomHeightInObjectSpace, intersectPoint.z);
	
	// Rotation
	// rotate the final position based on the direction the normal faces
	// so that the walls don't jump when we turn a corner
//	{
//		vec3 rotatedX = cross(Tangent, Normal);
//		mat3 rot = mat3(rotatedX, Tangent, Normal);
//
//		textureCoord = rot * textureCoord;
//	}
//
	FragColor = texture(CubeMap, textureCoord);

	// DEBUGGING
//	FragColor = vec4(Position.y/RoomHeight, 0.0, 0.0, 1.0);
//	FragColor = vec4(eye / 2 + vec3(0.5, 0.5, 0.5), 1.0); // OK
//	FragColor = vec4(parametricT, 0.0, 0.0, 1.0); // PROBLEM here. 
//	float y = abs(TexCoord.y/eye.y);
//	FragColor = vec4(y / 10, 0.0, 0.0, 1.0); // PROBLEM here. 
//	FragColor = vec4(vec3(TexCoord.xy, 1.0), 1.0); // OK
	FragColor = vec4(textureCoord * 0.5 + vec3(0.5, 05, 0.5), 1.0);
}