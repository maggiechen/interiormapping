#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;
layout (location = 2) in vec3 normal;
layout (location = 3) in vec3 tangent;

out vec2 TexCoord;
out vec3 Tangent;
out vec3 Normal;
out vec3 Position;

uniform vec3 EyePos;
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    // A non uniform scale matrix for the model is not supported as the uv coordinates
    // cannot be adjusted according to the non uniform scale without using branching, which is expensive

    vec4 worldPos = model * vec4(aPos, 1.0);
    gl_Position = projection * view * worldPos;

    TexCoord = aTexCoord * 2 - vec2(1, 1);
    Tangent = tangent;
    Normal = normal;
    Position = worldPos.xyz;
}
