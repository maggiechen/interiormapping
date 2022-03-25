
#pragma once
#include <GLFW/glfw3.h>
#include <glm/fwd.hpp>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
class Main;


class MouseControlledCamera
{

    static bool firstMouse;
    static float yaw;
    static float pitch;
    static float lastX, lastY;
    static float fov;
    static constexpr float m_sensitivity = 0.1f;
public:
    MouseControlledCamera();
    static void MouseCallback(GLFWwindow* window, double xpos, double ypos);
    static void ScrollCallback(GLFWwindow* window, double xpos, double ypos);
    static void GetLookDirection(glm::vec3& direction);
    friend Main;
};

