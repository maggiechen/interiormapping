#pragma once
#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include <iostream>


class Main
{
private:
	static int s_windowWidth;
	static int s_windowHeight;
	GLFWwindow* m_window;
public:
	int Run();
private:
	int RunGameLoop();

	int LoadOpenGLFunctions();
	void InitGLFW();
	void DestroyGLFW();
	int CreateWindow();

	static void FramebufferSizeCallback(GLFWwindow* window, int newWidth, int newHeight);
};

