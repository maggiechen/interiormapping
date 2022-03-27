#include "MouseControlledCamera.h"


float MouseControlledCamera::yaw;
float MouseControlledCamera::pitch;
float MouseControlledCamera::lastX, MouseControlledCamera::lastY;
float MouseControlledCamera::fov;
bool MouseControlledCamera::firstMouse;

MouseControlledCamera::MouseControlledCamera()
{
	lastY = 300;
	lastX = 400;
	yaw = -90.0f;
	fov = 45.0f;
	firstMouse = true;
}

void MouseControlledCamera::GetLookDirection(glm::vec3& direction)
{
	direction.x = cos(glm::radians(yaw)) * cos(glm::radians(pitch));
	direction.y = sin(glm::radians(pitch));
	direction.z = sin(glm::radians(yaw)) * cos(glm::radians(pitch));
}

void MouseControlledCamera::MouseCallback(GLFWwindow* window, double xpos, double ypos)
{
	// prevent big mouse jump when mouse first enters window
	if (firstMouse)
	{
		lastX = xpos;
		lastY = ypos;
		firstMouse = false;
	}
	float xOffset = xpos - lastX;
	float yOffset = - ypos + lastY; // negate this in an fps if player wants inverted up/down
	lastX = xpos;
	lastY = ypos;
	yaw += xOffset * m_sensitivity;
	pitch += yOffset * m_sensitivity;
	if (pitch > 89.0f)
		pitch = 89.0f;
	if (pitch < -89.0f)
		pitch = -89.0f;
}


void MouseControlledCamera::ScrollCallback(GLFWwindow* window, double xoffset, double yoffset)
{
	fov -= (float)yoffset * m_sensitivity;
	if (fov < 1.0f)
		fov = 1.0f;
	if (fov > 45.0f)
		fov = 45.0f;
}
