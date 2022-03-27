#pragma once
#include <glad/glad.h>
#include "VertexBufferLayout.h"
class Geometry
{
public:
    static void CreateRectangle(GLuint& VAO, const float* vertices, size_t size, const int* elements, size_t elemSize);

};
