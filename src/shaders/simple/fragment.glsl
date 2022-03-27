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
    vec3 bitangent = cross(Normal, Tangent);
    mat3 worldToTangent = mat3(bitangent, Normal, Tangent);
    vec3 eye = normalize(worldToTangent * normalize (EyePos - Position));


	// tangent as color
//	FragColor = vec4(eye, 1.0) / 2 + vec4(0.5, 0.5, 0.5, 1.0);
	// into the cube map
//	FragColor = texture(cubemap, eye);

	float parametricT = min(min(
		abs(1/eye.x) - TexCoord.x/eye.x,
		abs(1/eye.z) - TexCoord.y/eye.z),
		-1/eye.y);


	vec3 index = parametricT * eye + vec3(TexCoord, 1.0);
	FragColor = texture(cubemap, index);
//	
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