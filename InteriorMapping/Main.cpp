#include "Main.h"

int main(int argc, char* argv[])
{
	std::string fullPathToExe = argv[0];
	std::string appPath = fullPathToExe.substr(0, fullPathToExe.find_last_of("\\"));
	Main m(appPath);
	m.Run();
}

// static member variables in C++ are not initialized within the class
// but outside of it. This gives you more control than languages like C#
// where you may not have control over the order of initialization of
// static members.
int Main::s_windowHeight = 600;
int Main::s_windowWidth = 800;

Main::Main(std::string appPath)
{
	m_appPath = appPath;

}

int Main::Run()
{
	InitGLFW();
	int ret = 0;

	if (ret = CreateWindow())
	{
		return ret;
	}
	
	
	unsigned int VAO;
	Geometry::CreateRectangle(VAO, m_verticesCube, sizeof(m_verticesCube));
	auto vertPath = m_appPath + "\\vertex.glsl";
	auto fragPath = m_appPath + "\\fragment.glsl";
	Shader* shader = new Shader(vertPath.c_str(), fragPath.c_str());

	unsigned int textureID;
	glGenTextures(1, &textureID);
	glBindTexture(GL_TEXTURE_CUBE_MAP, textureID);

	std::vector<std::string> textureImages = {
		"0.png",
		"1.png",
		"2.png",
		"3.png",
		"4.png",
		"5.png"
	};
	int width, height, channelCount;
	unsigned char* data;
	for (unsigned int i = 0; i < textureImages.size(); i++) {
		data = stbi_load((m_appPath + "\\" + textureImages[i]).c_str(), &width, &height, &channelCount, 0);
		glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
		stbi_image_free(data);
	}

	RunGameLoop(shader, VAO, textureID);

	DestroyGLFW();

	return ret;
}

int Main::RunGameLoop(Shader* shader, unsigned int& VAO, unsigned int& textureID)
{
	MouseControlledCamera m; // initialize the static fields
	// mouse input
	glfwSetInputMode(m_window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
	glfwSetCursorPosCallback(m_window, MouseControlledCamera::MouseCallback);
	glfwSetScrollCallback(m_window, MouseControlledCamera::ScrollCallback);
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	glEnable(GL_DEPTH_TEST);
	while (!glfwWindowShouldClose(m_window))
	{
		float currentFrame = (float)glfwGetTime();
		m_deltaTime = currentFrame - m_lastFrame;
		m_lastFrame = currentFrame;
		ProcessKeyboardInput();

		glClearColor(0.3f, 0.6f, 0.1f, 1.0f); // fill bg colour

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		glBindTexture(GL_TEXTURE_2D, textureID);
		shader->use();
		MouseControlledCamera::GetLookDirection(m_lookDir);
		glm::mat4 model = glm::mat4(1.0f), view = glm::mat4(1.0f), projection = glm::mat4(1.0f);
		view = glm::lookAt(m_cameraPos, m_cameraPos + m_lookDir, m_worldUp);
		projection = glm::perspective(MouseControlledCamera::fov, ((float)s_windowWidth) / s_windowHeight, 0.1f, 100.0f);
		shader->setMat4("model", glm::value_ptr(model));
		shader->setMat4("view", glm::value_ptr(view));
		shader->setMat4("projection", glm::value_ptr(projection));
		shader->setVec3("EyePos", m_cameraPos);

		glBindVertexArray(VAO);
		glDrawArrays(GL_TRIANGLES, 0, 36);

		glfwPollEvents();
		glfwSwapBuffers(m_window);


	}
	return 0;
}

void Main::ProcessKeyboardInput() {

	if (glfwGetKey(m_window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
	{
		glfwSetWindowShouldClose(m_window, true);
	}

	float cameraSpeed = 2.5f * m_deltaTime;

	if (glfwGetKey(m_window, GLFW_KEY_W) == GLFW_PRESS)
		m_cameraPos += cameraSpeed * m_lookDir;
	if (glfwGetKey(m_window, GLFW_KEY_S) == GLFW_PRESS)
		m_cameraPos -= cameraSpeed * m_lookDir;
	if (glfwGetKey(m_window, GLFW_KEY_A) == GLFW_PRESS)
		m_cameraPos -= glm::normalize(glm::cross(m_lookDir, m_worldUp)) * cameraSpeed;
	if (glfwGetKey(m_window, GLFW_KEY_D) == GLFW_PRESS)
		m_cameraPos += glm::normalize(glm::cross(m_lookDir, m_worldUp)) * cameraSpeed;
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

