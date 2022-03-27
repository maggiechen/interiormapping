#pragma once

// OpenGL loader GLAD
#include <glad/glad.h>

// UI library GLFW
#include <GLFW/glfw3.h>

// GLM math library
#include <glm/fwd.hpp>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

// image library
#include <stb/stb_image.h>

// C++ standard libraries
#include <iostream>
#include <vector>

// Other headers in this project
#include "Geometry.h"
#include "MouseControlledCamera.h"
#include "Shader.h"
#include "VertexBufferLayout.h"

class Main
{
private:
    std::string m_appPath;

    const float m_verticesCube[396] = {
    // POSITION           UV COORD      NORMAL            TANGENT
    // plane facing negative z
    // triangle from negative corner
    -0.5f, -0.5f, -0.5f,  1.0f, 0.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
     0.5f, -0.5f, -0.5f,  0.0f, 0.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
     0.5f,  0.5f, -0.5f,  0.0f, 1.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
     0.5f,  0.5f, -0.5f,  0.0f, 1.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
    -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
    -0.5f, -0.5f, -0.5f,  1.0f, 0.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
    // plane facing positive z
    // triangle from negative corner
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
     0.5f,  0.5f,  0.5f,  1.0f, 1.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
     0.5f,  0.5f,  0.5f,  1.0f, 1.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
    -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
    // plane facing negative x
    // triangle from positive corner
    -0.5f,  0.5f,  0.5f,  1.0f, 1.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    -0.5f,  0.5f, -0.5f,  1.0f, 0.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    -0.5f, -0.5f,  0.5f,  0.0f, 1.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    -0.5f,  0.5f,  0.5f,  1.0f, 1.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    // plane facing positive x
    // triangle from positive corner
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,   1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,   1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     0.5f, -0.5f, -0.5f,  0.0f, 1.0f,   1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     0.5f, -0.5f, -0.5f,  0.0f, 1.0f,   1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     0.5f, -0.5f,  0.5f,  0.0f, 0.0f,   1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,   1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     // plane facing negative y
     // triangle from negative corner
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
     0.5f, -0.5f, -0.5f,  1.0f, 1.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
    // plane facing positive y
    // triangle from negative corner
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
    -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
    };

    glm::vec3 m_cameraPos =     glm::vec3(0.0f, 0.0f, 3.0f); // start position
    glm::vec3 m_lookDir =   glm::vec3(0.0, 0.0, -1.0f); // looking down local negative z axis
    glm::vec3 m_worldUp =       glm::vec3(0.0, 1.0f, 0.0); // world up vector (+y axis)
	static int s_windowWidth;
	static int s_windowHeight;
	GLFWwindow* m_window;
    float m_deltaTime = 0.0f;
    float m_lastFrame = 0.0f;
public:
    Main(std::string appPath);
	int Run();
private:
	int RunGameLoop(Shader* shader, unsigned int& VAO, unsigned int& textureID);
    void ProcessKeyboardInput();

	int LoadOpenGLFunctions();
	void InitGLFW();
	void DestroyGLFW();
	int CreateWindow();

	static void FramebufferSizeCallback(GLFWwindow* window, int newWidth, int newHeight);
};

