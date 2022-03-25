#include "Geometry.h"

void Geometry::CreateRectangle(GLuint& VAO, const float* vertices, size_t size)
{
    // array object to store raw vertices, element buffers, and vertex attribute settings
    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);

    // raw vertices
    unsigned int VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, size, vertices, GL_STATIC_DRAW);

    // element buffer

    VertexBufferLayout vertexBufferLayout(std::vector<int>{3, 2});
    vertexBufferLayout.Process();
}