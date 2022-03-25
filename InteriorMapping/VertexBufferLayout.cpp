#include "VertexBufferLayout.h"

void VertexBufferLayout::Process()
{
    GLsizei stride = 0;

    for (auto&& attributeSize : m_layout) {
        stride += attributeSize;
    }
    stride *= sizeof(float);

    int offset = 0;
    for (int i = 0; i < m_layout.size(); ++i) {
        glVertexAttribPointer(i, m_layout[i], GL_FLOAT, GL_FALSE, stride, (void*)(offset * sizeof(float)));
        offset += m_layout[i];
        glEnableVertexAttribArray(i);
    }
}
