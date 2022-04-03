#version 330 core
out vec4 FragColor;
in vec3 Position;
in vec3 ObjectPos;
in vec2 TexCoord;
in vec3 Tangent;
in vec3 Normal;
uniform vec3 EyePos;
uniform samplerCube CubeMap;

uniform float WorldToObjectScaleX;
uniform float WorldToObjectScaleY;
uniform float WorldToObjectScaleZ;

uniform float RoomWidth;
uniform float RoomHeight;
uniform float RoomDepth;

// ASSUMPTIONS:
// We assume the pivot of the object is at y = 0, in the center.


// DEBUG FUNCTIONS ============
//
vec3 interiorSpaceToObjectSpace(float spaceVal)
{
	float piece = spaceVal * 0.5 + 0.5;
	return vec3(piece, piece, piece);
}
// ====

// Return 1/(1+e^f)
float sigmoid(float f)
{
	float e = 2.71828;
	float exponent = pow(e, -f);
	return 1 / (1 + exponent);
}

// Convert 1 value from object space [0, 1] to interior space [-1, 1]
float interiorSpaceToObjectSpace1(float spaceVal)
{
	return spaceVal * 0.5 + 0.5;
}

// Convert 1 value from interior space [-1, 1] to object space [0, 1]
float objectSpaceToInteriorSpace1(float f)
{
	return 2 * f - 1;
}

float scaledTextureAxis(float intersectPointValue, float lowerBoundPlaneValue, float roomSizeInObjectSpaceForAxis)
{
	return 2 * (interiorSpaceToObjectSpace1(intersectPointValue) - interiorSpaceToObjectSpace1(lowerBoundPlaneValue))/roomSizeInObjectSpaceForAxis - 1;
}

void main()
{
    vec3 bitangent = cross(Tangent, Normal);

	// TODO: why do we need to transpose?
    mat3 worldToTangent = transpose(mat3(bitangent, Tangent, Normal));

	// the vector going towards the interior surface from the entry position
    vec3 eye = -normalize(worldToTangent * (EyePos - Position));
	
	// on [0, 1]
	float RoomWidthInObjectSpace = RoomWidth * WorldToObjectScaleX;
	float RoomHeightInObjectSpace = RoomHeight * WorldToObjectScaleY;
	float RoomDepthInObjectSpace = RoomDepth * WorldToObjectScaleZ;
	float RoomHorizontalSizeInObjectSpace = abs(dot(bitangent, vec3(RoomWidthInObjectSpace, 0, RoomDepthInObjectSpace)));

	float verticalRoomCountContinuous = Position.y/RoomHeight;

	// translate the x and z since they're on [-1, 1] right now
	float ObjectToWorldScaleX = 1 / WorldToObjectScaleX; // TODO: this would be better as a uniform
	float ObjectToWorldScaleZ = 1 / WorldToObjectScaleZ; // TODO: this would be better as a uniform
	

	vec3 posXCandidates = vec3(Position.x, 0, Position.z);
	
	// we don't support different scales along axes yet so this isn't quite necessary
	// but doing this in case we do in the future
	float halfFaceX = 0.5 * ObjectToWorldScaleX;
	float halfFaceZ = 0.5 * ObjectToWorldScaleZ;
	vec3 shiftXCandidates = vec3(halfFaceX, 0, halfFaceZ);

	// multiply 1000 to make the sigmoid function almost a step function
//	float bitangentSign = dot(vec3(1, 1, 1), bitangent) * 1000;
//	float bumpForNegativeAxisBitangentScenario = 1 - sigmoid(bitangentSign);

	float PosXRepivoted =
		dot(posXCandidates, bitangent)
		+ abs(dot(bitangent, shiftXCandidates));

	float horizontalRoomSize = abs(dot(bitangent, vec3(RoomWidth, 0, RoomDepth)));
	float horizontalRoomCountContinuous = PosXRepivoted / horizontalRoomSize;

	// Get the planes for intersection, all in interior space [-1, 1]
	// positive x
	float xRight = objectSpaceToInteriorSpace1(ceil(horizontalRoomCountContinuous) * RoomHorizontalSizeInObjectSpace);
	// negative x
	float xLeft = objectSpaceToInteriorSpace1(floor(horizontalRoomCountContinuous) * RoomHorizontalSizeInObjectSpace);
	// positive y
	float yTop = objectSpaceToInteriorSpace1(ceil(verticalRoomCountContinuous) * RoomHeightInObjectSpace);
	// negative y
	float yBottom = objectSpaceToInteriorSpace1(floor(verticalRoomCountContinuous) * RoomHeightInObjectSpace);

	// Get parameter T for optimal y plane intersection
	float yTopIntersectT = yTop/eye.y-TexCoord.y/eye.y;
	float yBottomIntersectT = yBottom/eye.y-TexCoord.y/eye.y;
	float yIntersectionT = max(yTopIntersectT, yBottomIntersectT);

	// Get parameter T for optimal x plane intersection
	float xRightIntersectT = (xRight/eye.x) - (TexCoord.x/eye.x);
	float xLeftIntersectT = (xLeft/eye.x) - (TexCoord.x/eye.x);
	float xIntersectionT = max(xRightIntersectT, xLeftIntersectT);

	// Get parameter T for optimal intersection among x and y plane intersections
	float xyIntersectionT = min(xIntersectionT, yIntersectionT);

	float RoomHorizontalDepthSizeInObjectSpace = abs(dot(Normal, vec3(RoomWidthInObjectSpace, 0, RoomDepthInObjectSpace)));
	float zPlaneToUse = 1 - RoomHorizontalDepthSizeInObjectSpace;

	// Get parameter T for optimal intersection among x, y, and z plane intersections
	float parametricT = min(
		xyIntersectionT,
		(zPlaneToUse - 1)/eye.z); // assume the z component of the eye vector is in the positive z axis

	// need z = 1.0 because the raycast starts from the entry position, which is not the origin
	// of the interior space, but 1 unit before it.
	vec3 intersectPoint = parametricT * eye + vec3(TexCoord.xy, 1.0);

	// Scale texture indexing so that wall samples stretch and repeat to fit room size
	float u = scaledTextureAxis(intersectPoint.x, xLeft, RoomHorizontalSizeInObjectSpace);
	float v = scaledTextureAxis(intersectPoint.y, yBottom, RoomHeightInObjectSpace);
	float t = scaledTextureAxis(intersectPoint.z, zPlaneToUse, RoomHorizontalDepthSizeInObjectSpace);
	vec3 textureCoord = vec3(u, v, t);
	
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
//	FragColor = vec4(verticalRoomCountContinuous, verticalRoomCountContinuous, verticalRoomCountContinuous, 1.0);

//	FragColor = vec4(
//		ceil(verticalRoomCountContinuous) * RoomHeightInObjectSpace,
//		ceil(verticalRoomCountContinuous) * RoomHeightInObjectSpace,
//		ceil(verticalRoomCountContinuous) * RoomHeightInObjectSpace, 1.0);
//	FragColor = vec4(interiorSpaceToObjectSpace(yIntersectionT * eye.y + TexCoord.y), 1.0);
	
//	FragColor = vec4(vec3(yTopIntersectT, yTopIntersectT, yTopIntersectT), 1.0);
//	FragColor = vec4(vec3(xRightIntersectT, xRightIntersectT, xRightIntersectT), 1.0);
//	FragColor = vec4(vec3(parametricT, parametricT, parametricT), 1.0);
//	FragColor = vec4(intersectPoint, 1.0);

//	FragColor = vec4(sigmoid(10* eye.x), 0.0, 0.0, 1.0);
//	FragColor = vec4(vec3(xyIntersectionT, xyIntersectionT, xyIntersectionT), 1.0);
//	FragColor = vec4(interiorSpaceToObjectSpace(yBottom), 1.0);
//	FragColor = vec4(PosXRepivoted, 0.0, 0.0, 1.0);
//	FragColor = vec4(bumpForNegativeAxisBitangentScenario, bumpForNegativeAxisBitangentScenario, bumpForNegativeAxisBitangentScenario, 1.0);
//	FragColor = vec4(interiorSpaceToObjectSpace(t), 1.0);
//	float zPlaneV = interiorSpaceToObjectSpace1(zPlaneToUse);
//	float thing = interiorSpaceToObjectSpace1(intersectPoint.z) - zPlaneV;
//	float c = (thing)/RoomHorizontalDepthSizeInObjectSpace;
//	FragColor = vec4(thing, thing, thing, 1.0);
//	FragColor = vec4(RoomHorizontalDepthSizeInObjectSpace, RoomHorizontalDepthSizeInObjectSpace, RoomHorizontalDepthSizeInObjectSpace, 1.0);
//	FragColor = vec4(c, c, c, 1.0);
//	FragColor = vec4(zPlaneV, zPlaneV, zPlaneV, 1.0); // makes sense
//	FragColor = vec4(u, u, u, 1.0);
}