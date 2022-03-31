#version 330 core
out vec4 FragColor;
in vec3 Position;
in vec2 TexCoord;
in vec3 Tangent;
in vec3 Normal;
uniform vec3 EyePos;
uniform vec3 WorldUp;
uniform samplerCube cubemap;

void main()
{
    vec3 bitangent = cross(Tangent, Normal);

	// TODO: why do we need to transpose?
    mat3 worldToTangent = transpose(mat3(bitangent, Tangent, Normal));

	// the vector going towards the interior surface from the entry position
    vec3 eye = -normalize(worldToTangent * (EyePos - Position));

	float parametricT = min(min(
		abs(1/eye.x) - TexCoord.x/eye.x,
		abs(1/eye.y) - TexCoord.y/eye.y),
		-2/eye.z); // assume the z component of the eye vector is in the positive z axis
	
	// need z=1.0 because the raycast starts from the entry position, which is not the origin
	// of the interior space, but 1 unit before it.
	vec3 index = parametricT * eye + vec3(TexCoord.xy, 1.0);
	
	// rotate the final position based on the direction the normal faces
	// so that the walls don't jump when we turn a corner
	vec3 rotatedX = cross(WorldUp, Normal);
	mat3 rot = mat3(rotatedX, WorldUp, Normal);

	index = rot * index;

	FragColor = texture(cubemap, index);

}