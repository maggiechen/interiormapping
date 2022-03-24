#include "Main.h"


int main()
{
	Main m;
	m.Run();
}

// static member variables in C++ are not initialized within the class
// but outside of it. This gives you more control than languages like C#
// where you may not have control over the order of initialization of
// static members.
int Main::s_windowHeight = 600;
int Main::s_windowWidth = 800;

int Main::Run()
{
	InitGLFW();
	int ret = 0;

	if (ret = CreateWindow())
	{
		return ret;
	}
	RunGameLoop();

	DestroyGLFW();

	return ret;
}

int Main::RunGameLoop()
{
	while (!glfwWindowShouldClose(m_window))
	{
		glfwSwapBuffers(m_window);
		glfwPollEvents();
	}
	return 0;
}

int Main::LoadOpenGLFunctions()
{
	auto functionThatReturnsAddressToOpenGLFunctions = (GLADloadproc)glfwGetProcAddress;
	if (!gladLoadGLLoader(functionThatReturnsAddressToOpenGLFunctions))
	{
		std::cout << "Couldn't load GLAD, which loads the OpenGL functions" << std::endl;
		return -1;
	}
	return 0;
}

void Main::InitGLFW()
{
	glfwInit();
}

void Main::DestroyGLFW()
{
	glfwTerminate();
}

int Main::CreateWindow()
{
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

	m_window = glfwCreateWindow(s_windowWidth, s_windowHeight, "Interior Mapping Demo", NULL, NULL);
	if (m_window == NULL)
	{
		std::cout << "GLFW window is busted" << std::endl;
		DestroyGLFW();
		return -1;
	}

	glfwMakeContextCurrent(m_window);

	// Functions must be retrieved *after* context (OpenGL = 3.3) is made current.
	// Any earlier and calls to OpenGL functions, e.g. glfwSetFramebufferSizeCallback below,
	// results in undefined behaviour, such as crashes
	int ret = 0;
	if (ret = LoadOpenGLFunctions())
	{
		return ret;
	}

	glViewport(0, 0, s_windowWidth, s_windowHeight);
	glfwSetFramebufferSizeCallback(m_window, FramebufferSizeCallback);
	return 0;
}

void Main::FramebufferSizeCallback(GLFWwindow* window, int width, int height)
{
	s_windowWidth = width;
	s_windowHeight = height;
	glViewport(0, 0, s_windowWidth, s_windowHeight);
}
