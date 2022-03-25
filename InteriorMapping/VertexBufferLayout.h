#pragma once
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <vector>


/// <summary>
/// A utility class for doing all the vertex attribute initialization. It's really annoying having to
/// do the addition every single time. With this, you just need to provide the sizes of the attributes
/// in units of array elements as a list to the constructor, and then call Process() to inform OpenGL
/// of the layout of the attributes. Note that it expects the order to be sequential starting from layout
/// location 0.
/// </summary>
class VertexBufferLayout
{
private:
    std::vector<int> m_layout;
public:
    VertexBufferLayout(std::vector<int>&& layout) : m_layout(layout) {}
    void Process();
};

