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


// DEBUG FUNCTIONS ============
//
//vec3 interiorSpaceToObjectSpace(float spaceVal)
//{
//	float piece = spaceVal * 0.5 + 0.5;
//	return vec3(piece, piece, piece);
//}
//

//float sigmoid(float f)
//{
//	float e = 2.71828;
//	float exponent = pow(e, -f);
//	return 1 / (1 + exponent);
//}


float interiorSpaceToObjectSpace1(float spaceVal)
{
	return spaceVal * 0.5 + 0.5;
}

float objectSpaceToInteriorSpace1(float f)
{
	return 2 * f - 1;
}


void main()
{
    vec3 bitangent = cross(Tangent, Normal);

	// TODO: why do we need to transpose?
    mat3 worldToTangent = transpose(mat3(bitangent, Tangent, Normal));

	// the vector going towards the interior surface from the entry position
    vec3 eye = -normalize(worldToTangent * (EyePos - Position));
	
	// on [0, 1]
	float RoomHeightInObjectSpace = RoomHeight * ObjectPos.y / Position.y;

	float roomCountContinuous = Position.y/RoomHeight;

	// on [-1, 1]
	float yTop = objectSpaceToInteriorSpace1(ceil(roomCountContinuous) * RoomHeightInObjectSpace);
	float yBottom = objectSpaceToInteriorSpace1(floor(roomCountContinuous) * RoomHeightInObjectSpace);
	
	// Get parameter T for optimal y plane intersection
	float yTopIntersectT = yTop/eye.y-TexCoord.y/eye.y;
	float yBottomIntersectT = yBottom/eye.y-TexCoord.y/eye.y;
	float yIntersectionT = max(yTopIntersectT, yBottomIntersectT);

	// Get parameter T for optimal x plane intersection
	float xBottomIntersectT = (1/eye.x) - (TexCoord.x/eye.x);
	float xTopIntersectT = (-1/eye.x) - (TexCoord.x/eye.x);
	float xIntersectionT = max(xBottomIntersectT, xTopIntersectT);

	// Get parameter T for optimal intersection among x and y plane intersections
	float xyIntersectionT = min(xIntersectionT, yIntersectionT);

	// Get parameter T for optimal intersection among x, y, and z plane intersections
	float parametricT = min(
		xyIntersectionT,
		-2/eye.z); // assume the z component of the eye vector is in the positive z axis

	// need z = 1.0 because the raycast starts from the entry position, which is not the origin
	// of the interior space, but 1 unit before it.
	vec3 intersectPoint = parametricT * eye + vec3(TexCoord.xy, 1.0);

	// Scale texture indexing so that wall samples stretch and repeat to fit room size
	vec3 textureCoord = vec3(
		intersectPoint.x,
		2 * (interiorSpaceToObjectSpace1(intersectPoint.y) - interiorSpaceToObjectSpace1(yBottom))/RoomHeightInObjectSpace - 1,
		intersectPoint.z
	);
	
	// Rotation
	// rotate the final position based on the direction the normal faces
	// so that the walls don't jump when we turn a corner
	{
		vec3 rotatedX = cross(Tangent, Normal);
		mat3 rot = mat3(rotatedX, Tangent, Normal);

		textureCoord = rot * textureCoord;
	}

	FragColor = texture(CubeMap, textureCoord);

	// DEBUGGING
//	FragColor = vec4(Position.y/RoomHeight, 0.0, 0.0, 1.0);
//	FragColor = vec4(eye / 2 + vec3(0.5, 0.5, 0.5), 1.0); // OK
//	FragColor = vec4(parametricT, 0.0, 0.0, 1.0); // PROBLEM here. 
//	float y = abs(TexCoord.y/eye.y);
//	FragColor = vec4(y / 10, 0.0, 0.0, 1.0); // PROBLEM here. 
//	FragColor = vec4(vec3(TexCoord.xy, 1.0), 1.0); // OK
//	FragColor = vec4(textureCoord * 0.5 + vec3(0.5, 05, 0.5), 1.0);
//	FragColor = vec4(Position.y, Position.y, Position.y, 1.0);
//	FragColor = vec4(roomCountContinuous, roomCountContinuous, roomCountContinuous, 1.0);

//	FragColor = vec4(
//		ceil(roomCountContinuous) * RoomHeightInObjectSpace,
//		ceil(roomCountContinuous) * RoomHeightInObjectSpace,
//		ceil(roomCountContinuous) * RoomHeightInObjectSpace, 1.0);
//	FragColor = vec4(interiorSpaceToObjectSpace(yIntersectionT * eye.y + TexCoord.y), 1.0);
	
//	FragColor = vec4(vec3(yTopIntersectT, yTopIntersectT, yTopIntersectT), 1.0);
//	FragColor = vec4(vec3(yBottomIntersectT, yBottomIntersectT, yBottomIntersectT), 1.0);
//	FragColor = vec4(vec3(parametricT, parametricT, parametricT), 1.0);
//	FragColor = vec4(intersectPoint, 1.0);

//	FragColor = vec4(sigmoid(10* eye.x), 0.0, 0.0, 1.0);
//	FragColor = vec4(vec3(xyIntersectionT, xyIntersectionT, xyIntersectionT), 1.0);
//	FragColor = vec4(interiorSpaceToObjectSpace(yBottom), 1.0);
}