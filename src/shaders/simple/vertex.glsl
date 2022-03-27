#version 330 core
layout (location = 0) in vec3 aPos; // the position variable has attribute position 0
layout (location = 1) in vec2 aTexCoord;
layout (location = 2) in vec3 normal;
layout (location = 3) in vec3 tangent;

out vec2 TexCoord;
out vec3 Position;
out vec3 TangentSpaceEyeVector;
uniform vec3 EyePos;
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    vec4 worldPos = model * vec4(aPos, 1.0);
    gl_Position = projection * view * worldPos;
    Position = worldPos.xyz;

    vec3 bitangent = cross(normal, tangent);
    mat3 worldToTangent = mat3(tangent, normal, bitangent);

    TangentSpaceEyeVector = normalize(worldToTangent * (EyePos - Position));
    TexCoord = aTexCoord * 2 - vec2(1, 1);
}
