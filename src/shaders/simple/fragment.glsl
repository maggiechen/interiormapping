#version 330 core
out vec4 FragColor;
in vec3 Position;
in vec2 TexCoord;
in vec3 Tangent;
in vec3 Normal;
uniform vec3 EyePos;
uniform samplerCube cubemap;

void main()
{
    vec3 bitangent = cross(Tangent, Normal);

	// why do we need to transpose?
    mat3 worldToTangent = transpose(mat3(bitangent, Tangent, Normal));

	// the vector going towards the interior surface from the entry position
    vec3 eye = -normalize(worldToTangent * (EyePos - Position));

	float parametricT = min(min(
		abs(1/eye.x) - TexCoord.x/eye.x,
		abs(1/eye.y) - TexCoord.y/eye.y),
		-2/eye.z);

	vec3 index = parametricT * eye + vec3(TexCoord.xy, 1.0);
	FragColor = texture(cubemap, index);

	// tangent as color
//	FragColor = vec4(eye, 1.0) / 2 + vec4(0.5, 0.5, 0.5, 1.0);
	// into the cube map
//	FragColor = texture(cubemap, eye);


//	float parametricT = min(min(
//	min(1/eye.x - TexCoord.x/eye.x,
//	-1/eye.x - TexCoord.x/eye.x),
//	
//	min(1/eye.y - TexCoord.y/eye.y,
//	-1/eye.y - TexCoord.y/eye.y)),
//	0);
	// consistent
//	FragColor = (vec4(parametricT * eye, 2.0)) / 2 + vec4(0.5, 0.5, 0.5, 0.0);
	// consistent
//	FragColor = (vec4(parametricT * eye, 2.0) + vec4(TexCoord, 0.0, 0.0)) / 2 + vec4(0.5, 0.5, 0.5, 0.0);



// INCONSISTENT
//	FragColor = vec4(TexCoord, 0.0, 0.0);
	
	// debug
//	FragColor = vec4(eye, 0.0);
//	FragColor = vec4(TexCoord, 0.0, 0.0);
//	FragColor = vec4(parametricT/1.732050, 0.0, 0.0, 1.0);
//	FragColor = vec4(
//		min(
//			min((abs(1/eye.x) - TexCoord.x/eye.x),
//			(abs(1/eye.y) - TexCoord.y/eye.y)),
//			-2/eye.z
//		)/10,
//		0.0, 0.0, 1.0);
//	if (index.x < -0.99) {
//		FragColor = vec4(1.0, 0.0, 0.0, 1.0);
//	} else if (index.x > 0.99) {
//		FragColor = vec4(0.5, 0.0, 0.0, 1.0);
//	} else if (index.y < -0.99) {
//		FragColor = vec4(0.0, 1.0, 0.0, 1.0);
//	} else if (index.y > 0.99) {
//		FragColor = vec4(0.0, 0.5, 0.0, 1.0);
//	} else if (index.z < -0.99) {
//		FragColor = vec4(0.0, 0.0, 1.0, 1.0);
//	} else {
//		FragColor = vec4(1.0, 1.0, 0.0, 1.0);
//	}
//


//	FragColor = vec4(index, 1.0);
}