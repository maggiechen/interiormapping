#version 330 core
#define M_PI 3.1415926535897932384626433832795

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

uniform vec3 LightPosition;
uniform vec3 LightColor;
uniform vec3 MaterialColor;
uniform vec3 SpecularColor;
uniform vec3 AmbientColor;
uniform float Shininess;
uniform float PointLightAttenuationDistance;
uniform float SpotLightOuterAngleTerm;
uniform float SpotLightRangeTerm;
uniform vec3 SpotLightDirection;
// ASSUMPTIONS:
// We assume the pivot of the object is at y = 0, in the center.


// DEBUG FUNCTIONS ============
//
//vec3 interiorSpaceToObjectSpace(float spaceVal)
//{
//	float piece = spaceVal * 0.5 + 0.5;
//	return vec3(piece, piece, piece);
//}
//
// ====

// Return 1/(1+e^f)
float sigmoid(float f)
{
	float e = 2.71828;
	float exponent = pow(e, -f);
	return 1 / (1 + exponent);
}

vec3 maxByLength(vec3 a, vec3 b)
{
	if (length(a) > length(b))
	{
		return a;
	}
	return b;
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
	float reflectAmount = 0.5;
	float transmitAmount = 1 - reflectAmount;
	vec3 eyeVec = normalize(EyePos - Position);

	// all done in world space
	vec3 unnormalizedLightVec = LightPosition - Position;
	float distanceToLight = length(unnormalizedLightVec);
	vec3 lightVec = normalize(unnormalizedLightVec);
	vec3 diffuse = dot(lightVec, Normal) * MaterialColor;
	vec3 halfVec = normalize(lightVec + eyeVec);

	vec3 specular = pow(max(0, dot(Normal, halfVec)), Shininess * 1.5) * SpecularColor; // we'll make the external glass a lot shinier
	// half vectors are annoying because it can allow light to contribute even when it's below the surface.
	// Need to account for this.
	
	// This mask will be 0 when light is below surface, 1 when above. The 1000 is to make the sigmoid like a step func
	float lightMask = sigmoid(1000*dot(lightVec, Normal));
	
	// We'll apply it in the final lightComponent because the spot light calculation has
	// a similar problem of contributing even when the light is below the surface.

	// max(0, 1 - (d^2 / r^2)) ^ 2
	// source: https://catlikecoding.com/unity/tutorials/custom-srp/point-and-spot-lights/
	float pointLightAtten = pow(max(0, 1 - pow(distanceToLight / PointLightAttenuationDistance, 2)), 2);

	float spotLightAtten;
	// calculate spot light attenuation using formula from https://catlikecoding.com/unity/tutorials/custom-srp/point-and-spot-lights/

	{
		// dotSpotLight defines where along the spot light penumbra we are
		float dotSpotLight = max(0, dot(-lightVec, SpotLightDirection)); // doesn't account for the light being below the surface, but this will be handled by the lightMask
		// this creates the attenuation over the range from the inner angle to the outer angle of the spotlight
		float spotLightFn = (dotSpotLight - SpotLightOuterAngleTerm) / SpotLightRangeTerm;
		// clamp over [0, 1] and raise to the power of 2
		spotLightAtten = pow(clamp(spotLightFn, 0.0, 1.0), 2);
	}

	vec3 lightComponent = (diffuse + specular) * LightColor * pointLightAtten * spotLightAtten * lightMask + AmbientColor;

	float ObjectToWorldScaleX = 1 / WorldToObjectScaleX; // TODO: this would be better as a uniform
	float ObjectToWorldScaleZ = 1 / WorldToObjectScaleZ; // TODO: this would be better as a uniform
	float ObjectToWorldScaleY = 1 / WorldToObjectScaleY;

	vec3 interiorColour;
	{
		vec3 bitangent = cross(Tangent, Normal);

		mat3 inverseWorldToTangent = transpose(mat3(bitangent, Tangent, Normal));
		{
		// Q: Why do we need to transpose here?
		// A: When we want to transform a vector from coordinate frame A to coordinate frame B,
		// we need to use the transpose(inverse(T)) where T is the transformation matrix
		// When the transformation matrix is a basis matrix (3 orthonormal vectors), the inverse
		// is simply the transpose, which means you get transpose(transpose(T)) = T
		// 
		// However, in our situation, note that we are NOT transforming the eye vector itself
		// from one position to another. Instead, we want to express the eye vector, which
		// is currently in world space, in terms of what its values would be in tangent space.
		// "Expressing in terms of" instead of "transforming into" means we actually want inverse(T).

		// You can confirm this by trying out this basic rotation:
		//	+-------------------------+                +---------------------------+
		//	|                         |                |                           |
		//	|    y ^                  |                |          ^ x              |
		//	|      |      vector v    |                |          |     vector v   |
		//	|      |    ----->        |                |          |   -------->    |
		//	|      |                  |                |          |                |
		//	|      |                  |       <-+      |          |                |
		//	|      +---------->       |         |      |  <-------+------->        |
		//	|      |         x        |                |  y               -y       |
		//	|      |                  |     rotate     |                           |
		//	|      |    |             |    90 degrees  |                           |
		//	|   -y |    | vector v'   |     ccw        |                           |
		//	|      v    |             |                |                           |
		//	|           |             |                |                           |
		//	|           v             |                |                           |
		//	|                         |                |                           |
		//	+-------------------------+                +---------------------------+
		//     BEFORE TRANSFORMATION						AFTER TRANSFORMATION
		// The transformation is a 90 degree rotation of the coordinate frame itself.
		// Since the goal isn't to move vector v, it stays in the same location after
		// the transformation is applied. From v's point of view, the effective
		// transformation is the exact inverse (which turns v into v'), a
		// 90 degree CLOCKWISE rotation

		// In our case, since we're using a basis matrix T, inverse(T) = transpose(T)
		// (Transposes are a lot easier on the GPU than inverses, which are expensive to compute)
		}
		// "eye" will be the eye vector in tangent space.
		vec3 eye = -normalize(inverseWorldToTangent * eyeVec);
		// ^ the vector going towards the interior surface from the entry position

		// "light" will be the light vector in tangent space
		vec3 light = normalize(inverseWorldToTangent * lightVec);

		// "spotLightDir" will be the spot light direction in tangent space
		vec3 spotLightDir = normalize(inverseWorldToTangent * SpotLightDirection);

		// on [0, 1]
		float RoomWidthInObjectSpace = RoomWidth * WorldToObjectScaleX;
		float RoomHeightInObjectSpace = RoomHeight * WorldToObjectScaleY;
		float RoomDepthInObjectSpace = RoomDepth * WorldToObjectScaleZ;
		float LocalRoomWidthInObjectSpace = abs(dot(Normal, vec3(RoomDepthInObjectSpace, RoomDepthInObjectSpace, RoomWidthInObjectSpace)));
		float LocalRoomDepthInObjectSpace = abs(dot(Normal, vec3(RoomWidthInObjectSpace, RoomHeightInObjectSpace, RoomDepthInObjectSpace)));
		float LocalRoomHeightInObjectSpace = abs(dot(Normal, vec3(RoomHeightInObjectSpace, RoomWidthInObjectSpace, RoomHeightInObjectSpace)));

		// translate the x and z since they're on [-1, 1] right now
		float LocalBuildingWidthInWorldSpace = abs(dot(Normal, vec3(ObjectToWorldScaleZ, ObjectToWorldScaleZ, ObjectToWorldScaleX)));
		float LocalBuildingDepthInWorldSpace = abs(dot(Normal, vec3(ObjectToWorldScaleZ, ObjectToWorldScaleZ, ObjectToWorldScaleX)));
		float LocalBuildingHeightInWorldSpace = abs(dot(Normal, vec3(ObjectToWorldScaleY, ObjectToWorldScaleX, ObjectToWorldScaleY)));
	
		vec3 localPosXCandidates = vec3(-Position.z, Position.z, Position.x);
	
		// we don't support different scales along axes yet so this isn't quite necessary
		// but doing this in case we do in the future
		float halfFaceX = 0.5 * ObjectToWorldScaleX;
		float halfFaceZ = 0.5 * ObjectToWorldScaleZ;
		vec3 shiftXCandidates = vec3(halfFaceZ, halfFaceZ, halfFaceX);

		float LocalPosX =
			dot(Normal, localPosXCandidates)
			+ abs(dot(Normal, shiftXCandidates));

		float localHorizontalRoomSize = abs(dot(Normal, vec3(RoomDepth, RoomDepth, RoomWidth)));
		float localHorizontalRoomCountContinuous = LocalPosX / localHorizontalRoomSize;

		// Handle local "vertical" rooms. For x/z faces this is the y axis, for y faces this is the x axis.
		vec3 localPosYCandidates = vec3(Position.y, Position.x, Position.y);
		float LocalPosY = dot(abs(Normal), localPosYCandidates) + abs(dot(Normal, vec3(0, 1, 0))) * halfFaceX;
		float localVerticalRoomSize = abs(dot(Normal, vec3(RoomHeight, RoomWidth, RoomHeight)));
		float localVerticalRoomCountContinuous = LocalPosY/localVerticalRoomSize;

		// Get the planes for intersection, all in interior space [-1, 1]
		// positive x
		float xRight = objectSpaceToInteriorSpace1(ceil(localHorizontalRoomCountContinuous) * LocalRoomWidthInObjectSpace);
		// negative x
		float xLeft = objectSpaceToInteriorSpace1(floor(localHorizontalRoomCountContinuous) * LocalRoomWidthInObjectSpace);
		// positive y
		float yTop = objectSpaceToInteriorSpace1(ceil(localVerticalRoomCountContinuous) * LocalRoomHeightInObjectSpace);
		// negative y
		float yBottom = objectSpaceToInteriorSpace1(floor(localVerticalRoomCountContinuous) * LocalRoomHeightInObjectSpace);

		// Get parameter T for optimal y plane intersection
		float yTopIntersectT = (yTop - TexCoord.y)/eye.y;
		float yBottomIntersectT = (yBottom - TexCoord.y)/eye.y;
		float yIntersectionT = max(yTopIntersectT, yBottomIntersectT);

		// Get parameter T for optimal x plane intersection
		float xRightIntersectT = (xRight - TexCoord.x)/eye.x;
		float xLeftIntersectT = (xLeft - TexCoord.x)/eye.x;
		float xIntersectionT = max(xRightIntersectT, xLeftIntersectT);

		// Get parameter T for optimal intersection among x and y plane intersections
		float xyIntersectionT = min(xIntersectionT, yIntersectionT);

		float zPlaneToUse = 1 - LocalRoomDepthInObjectSpace * 2; // object space is .5 of interior space, which is what we need to use

		// Get parameter T for optimal intersection among x, y, and z plane intersections
		float parametricT = min(
			xyIntersectionT,
			(zPlaneToUse - 1)/eye.z); // assume the z component of the eye vector is in the positive z axis

		// need z = 1.0 because the raycast starts from the entry position, which is not the origin
		// of the interior space, but 1 unit before it.
		vec3 intersectPointInInteriorSpace = parametricT * eye + vec3(TexCoord.xy, 1.0);

		// Scale texture indexing so that wall samples stretch and repeat to fit room size
		float u = scaledTextureAxis(intersectPointInInteriorSpace.x, xLeft, LocalRoomWidthInObjectSpace);
		float v = scaledTextureAxis(intersectPointInInteriorSpace.y, yBottom, LocalRoomHeightInObjectSpace);
		float t = scaledTextureAxis(intersectPointInInteriorSpace.z, zPlaneToUse, LocalRoomDepthInObjectSpace);
		vec3 preRotTextureCoord = vec3(u, v, t);
		vec3 textureCoord;
		// Rotation
		// rotate the final position based on the direction the normal faces
		// so that the walls don't jump when we turn a corner
		{
			vec3 rotatedX = cross(Tangent, Normal);
			mat3 rot = mat3(rotatedX, Tangent, Normal);
			textureCoord = rot * preRotTextureCoord ;
		}

		// find the normal of the interior surface that was struck, in stretched texture tangent space
		// using component-wise vector multiply to ascertain the axis the plane resides in
		vec3 planeAxisHit = maxByLength(
			abs(preRotTextureCoord) * vec3(1,0,0),
			maxByLength(
				abs(preRotTextureCoord) * vec3(0,1,0),
				abs(preRotTextureCoord) * vec3(0,0,1)));
		// account for negative/positive plane by multiplying again with the intersection point
		vec3 planeHit = planeAxisHit * preRotTextureCoord;
		// the normal should be the inverse
		vec3 planeHitNormal = -planeHit;
		
		vec3 diffuseComponent = texture(CubeMap, textureCoord).xyz * dot(light, planeHitNormal);

		float tangentSpotLightAtten;
		float tangentLightMask;
		vec3 interiorSpecular;
		float interiorPointLightAtten;
		// calculate spot light attenuation using formula from https://catlikecoding.com/unity/tutorials/custom-srp/point-and-spot-lights/
		{
			vec3 intersectionInTangentSpace = 0.5 * vec3(intersectPointInInteriorSpace.x, intersectPointInInteriorSpace.y, intersectPointInInteriorSpace.z - 1) * vec3(LocalBuildingWidthInWorldSpace, LocalBuildingHeightInWorldSpace, LocalBuildingDepthInWorldSpace);

			vec4 translate = vec4(0, 0.5*ObjectToWorldScaleY, 0, 0) + vec4(0.5 * LocalBuildingDepthInWorldSpace * Normal, 1);
			mat4 inverseWorldToTangentTranslateMat = mat4(
				vec4(1, 0, 0, 0),
				vec4(0, 1, 0, 0),
				vec4(0, 0, 1, 0),
				-translate);
			
			vec3 lightPositionInTangentSpace = inverseWorldToTangent * (inverseWorldToTangentTranslateMat * vec4(LightPosition, 1)).xyz;
			vec3 lightVecAtIntersectionWithPlaneInTangentSpace = normalize(lightPositionInTangentSpace - intersectionInTangentSpace);

			// tangentDotSpotLight defines where along the spot light penumbra we are
			float tangentDotSpotLight = max(0, dot(-lightVecAtIntersectionWithPlaneInTangentSpace, spotLightDir)); // doesn't account for the light being below the surface, but this will be handled by the lightMask
			// this creates the attenuation over the range from the inner angle to the outer angle of the spotlight
			float tangentSpotLightFn = (tangentDotSpotLight  - SpotLightOuterAngleTerm) / SpotLightRangeTerm;
			// clamp over [0, 1] and raise to the power of 2
			tangentSpotLightAtten = pow(clamp(tangentSpotLightFn , 0.0, 1.0), 2);

			// very important not to mess up the order of these args, because the first arg is the boundary that is used to compare
			// reversing them by accident will flip the effect.
			tangentLightMask = step(0, dot(planeHitNormal, lightVecAtIntersectionWithPlaneInTangentSpace));

			vec3 tangentHalfVec = normalize(lightVecAtIntersectionWithPlaneInTangentSpace - eye); // *note that we inverted the eye vector. now we need to undo that if we want the half vec
			interiorSpecular = pow(max(0, dot(planeHitNormal, tangentHalfVec)), Shininess) * SpecularColor;
			
			// max(0, 1 - (d^2 / r^2)) ^ 2
			// source: https://catlikecoding.com/unity/tutorials/custom-srp/point-and-spot-lights/
			float distanceToLightFromIntersection = length(lightPositionInTangentSpace - intersectionInTangentSpace);
			interiorPointLightAtten = pow(max(0, 1 - pow(distanceToLightFromIntersection / PointLightAttenuationDistance, 2)), 2);

//			debug = vec3(tangentDotSpotLight,tangentDotSpotLight,tangentDotSpotLight);
//			debug = spotLightDir;
//
//			debug = lightPositionInTangentSpace;
//			debug = -lightVecAtIntersectionWithPlaneInTangentSpace; // this should go into negatives.
//			debug = spotLightDir;

//			debug = intersectionInTangentSpace 
//			debug = vec3(tangentDotSpotLight, tangentDotSpotLight, tangentDotSpotLight);
//			debug = vec3(tangentLightMask , tangentLightMask , tangentLightMask );
//			debug = vec3(tangentSpotLightAtten * tangentLightMask, tangentSpotLightAtten * tangentLightMask, tangentSpotLightAtten * tangentLightMask);
//			debug = vec3(dot(planeHitNormal, tangentHalfVec), dot(planeHitNormal, tangentHalfVec), dot(planeHitNormal, tangentHalfVec));
		}

		interiorColour = transmitAmount * (diffuseComponent + interiorSpecular) * tangentSpotLightAtten * tangentLightMask * interiorPointLightAtten + AmbientColor;

		{
//		interiorColour = tangentSpotLightAtten * tangentLightMask + AmbientColor;
//		interiorColour = debug;
		// DEBUGGING
	//	FragColor = vec4(Position.y/RoomHeight, 0.0, 0.0, 1.0);
	//	FragColor = vec4(eye / 2 + vec3(0.5, 0.5, 0.5), 1.0); // OK
	//	FragColor = vec4(yIntersectionT, 0.0, 0.0, 1.0); // PROBLEM here. 
	//	float y = abs(TexCoord.y/eye.y);
	//	FragColor = vec4(y / 10, 0.0, 0.0, 1.0); // PROBLEM here. 
	//	FragColor = vec4(vec3(TexCoord.xy, 1.0), 1.0); // OK
	//	FragColor = vec4(textureCoord * 0.5 + vec3(0.5, 05, 0.5), 1.0);
	//	FragColor = vec4(Position.y, Position.y, Position.y, 1.0);
	//	FragColor = vec4(localVerticalRoomCountContinuous, localVerticalRoomCountContinuous, localVerticalRoomCountContinuous, 1.0);

	//	FragColor = vec4(
	//		ceil(localVerticalRoomCountContinuous) * RoomHeightInObjectSpace,
	//		ceil(localVerticalRoomCountContinuous) * RoomHeightInObjectSpace,
	//		ceil(localVerticalRoomCountContinuous) * RoomHeightInObjectSpace, 1.0);
	//	FragColor = vec4(interiorSpaceToObjectSpace(yIntersectionT * eye.y + TexCoord.y), 1.0);
	
	//	FragColor = vec4(vec3(yTopIntersectT, yTopIntersectT, yTopIntersectT), 1.0);
	//	FragColor = vec4(vec3(xRightIntersectT, xRightIntersectT, xRightIntersectT), 1.0);
	//	FragColor = vec4(vec3(parametricT, parametricT, parametricT), 1.0);
	//	FragColor = vec4(intersectPointInInteriorSpace, 1.0);

	//	FragColor = vec4(sigmoid(10* eye.x), 0.0, 0.0, 1.0);
	//	FragColor = vec4(vec3(xyIntersectionT, xyIntersectionT, xyIntersectionT), 1.0);
	//	FragColor = vec4(interiorSpaceToObjectSpace(yBottom), 1.0);
	//	FragColor = vec4(LocalPosX, 0.0, 0.0, 1.0);
	//	FragColor = vec4(bumpForNegativeAxisBitangentScenario, bumpForNegativeAxisBitangentScenario, bumpForNegativeAxisBitangentScenario, 1.0);
	//	FragColor = vec4(interiorSpaceToObjectSpace(t), 1.0);
	//	float zPlaneV = interiorSpaceToObjectSpace1(zPlaneToUse);
	//	float thing = interiorSpaceToObjectSpace1(intersectPointInInteriorSpace.z) - zPlaneV;
	//	float c = (thing)/LocalRoomDepthInObjectSpace;
	//	FragColor = vec4(thing, thing, thing, 1.0);
	//	FragColor = vec4(LocalRoomDepthInObjectSpace, LocalRoomDepthInObjectSpace, LocalRoomDepthInObjectSpace, 1.0);
	//	FragColor = vec4(c, c, c, 1.0);
	//	FragColor = vec4(zPlaneV, zPlaneV, zPlaneV, 1.0); // makes sense
	//	FragColor = vec4(localVerticalRoomCountContinuous / 6, localVerticalRoomCountContinuous/ 6, localVerticalRoomCountContinuous /6, 1.0);
		}
	}

	vec3 glowFromStreet = max(vec3(0, 0, 0), (pow(1 - Position.y/ObjectToWorldScaleY, 5) - 0.1) * LightColor * 0.3);
	FragColor = vec4(interiorColour + (lightComponent * reflectAmount) + glowFromStreet, 1.0);
}