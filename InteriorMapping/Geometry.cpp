#include "Geometry.h"

void Geometry::CreateRectangle(GLuint& VAO, const float* vertices, size_t size, const int* elements, size_t elemSize)
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
    unsigned int EBO;
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, elemSize, elements, GL_STATIC_DRAW);


    VertexBufferLayout vertexBufferLayout(std::vector<int>{3, 2, 3, 3});
    vertexBufferLayout.Process();
}