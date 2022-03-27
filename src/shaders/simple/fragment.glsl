#version 330 core
out vec4 FragColor;
in vec3 Position;
in vec2 TexCoord;
in vec3 TangentSpaceEyeVector;
uniform vec3 EyePos;
void main()
{
	vec3 eye = normalize(TangentSpaceEyeVector);

	// tangent as color
	FragColor = vec4(eye, 1.0) / 2 + vec4(0.5, 0.5, 0.5, 1.0);
//
//	float parametricT = min(min(
//		abs(1/eye.x) - TexCoord.x/eye.x,
//		abs(1/eye.y) - TexCoord.y/eye.y),
//		-1/eye.z);
//
//	vec3 index = parametricT * eye + vec3(TexCoord, 1.0);
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



//	FragColor = vec4(index, 1.0);
}