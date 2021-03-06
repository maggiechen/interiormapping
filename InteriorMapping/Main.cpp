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
	Geometry::CreateRectangle(VAO, VerticesCube, sizeof(VerticesCube), Elements, sizeof(Elements));
	auto vertPath = m_appPath + "\\vertex.glsl";
	auto fragPath = m_appPath + "\\fragment.glsl";

	auto debugVertPath = m_appPath + "\\debug_vertex.glsl";
	auto debugFragPath = m_appPath + "\\debug_fragment.glsl";

	Shader* shader = new Shader(vertPath.c_str(), fragPath.c_str());
	Shader* shader2 = new Shader(debugVertPath.c_str(), debugFragPath.c_str());
	unsigned int textureID;
	glGenTextures(1, &textureID);
	glBindTexture(GL_TEXTURE_CUBE_MAP, textureID);

	stbi_set_flip_vertically_on_load(true);

	static std::vector<std::string> textureImages = {
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

	RunGameLoop(shader, shader2, VAO, textureID);

	DestroyGLFW();

	return ret;
}

int Main::RunGameLoop(Shader* shader, Shader* shader2, unsigned int& VAO, unsigned int& textureID)
{
	MouseControlledCamera m; // initialize the static fields
	// mouse input
	glfwSetInputMode(m_window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
	glfwSetCursorPosCallback(m_window, MouseControlledCamera::MouseCallback);
	glfwSetScrollCallback(m_window, MouseControlledCamera::ScrollCallback);
	glPolygonMode(GL_FRONT, GL_FILL);
	glEnable(GL_CULL_FACE);
	glEnable(GL_DEPTH_TEST);
	glm::vec3 matColor = glm::vec3(0.2f, 0.3f, 0.3f);
	glm::vec3 specColor = glm::vec3(3.0, 3.0, 4.0); // let's say our material is an insulator
	glm::vec3 lightColor = glm::vec3(2.0f, 1.7f, 1.0f);
	glm::vec3 ambientColor = glm::vec3(0.1f, 0.03f, 0.1f);

	float pointLightAttenuationDistance = 10.0f;
	float shininess = 24.0;

	constexpr float spotLightInnerAngle = glm::pi<float>() / 6;
	constexpr float spotLightOuterAngle = glm::pi<float>() / 5.5f;
	float spotLightOuterAngleTerm = glm::cos(spotLightOuterAngle / 2);
	float spotLightRangeTerm = glm::cos(spotLightInnerAngle / 2) - glm::cos(spotLightOuterAngle / 2);
	while (!glfwWindowShouldClose(m_window))
	{
		float currentFrame = (float)glfwGetTime();
		m_deltaTime = currentFrame - m_lastFrame;
		if (!m_pause)
			m_gameTime += m_deltaTime;
		m_lastFrame = currentFrame;
		ProcessKeyboardInput();

		glClearColor(0.1f, 0.05f, 0.08f, 1.0f); // fill bg colour

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		glBindTexture(GL_TEXTURE_2D, textureID);
		shader->use();
		MouseControlledCamera::GetLookDirection(m_lookDir);
		shader->setVec3("EyePos", m_cameraPos);

		glm::mat4 lightModelMat = glm::mat4(0.3f);
		// light considerations
		{
			glm::vec3 lightPosition = glm::vec3(5 * sin(m_gameTime) + 1.0f, 6.0f, 5 * cos(m_gameTime));
			glm::vec3 spotLightDir = glm::normalize(-lightPosition);
			shader->setVec3("SpotLightDirection", spotLightDir);
			shader->setVec3("LightPosition", lightPosition);
			shader->setVec3("MaterialColor", matColor);
			shader->setFloat("Shininess", shininess);
			shader->setVec3("SpecularColor", specColor);
			shader->setVec3("LightColor", lightColor);
			shader->setVec3("AmbientColor", ambientColor);
			shader->setFloat("PointLightAttenuationDistance", pointLightAttenuationDistance);
			shader->setFloat("SpotLightOuterAngleTerm", spotLightOuterAngleTerm);
			shader->setFloat("SpotLightRangeTerm", spotLightRangeTerm);

			lightModelMat = glm::translate(lightModelMat, lightPosition);
		}

		// Set model, view, and projection matrices to identity matrix
		glm::mat4 model = glm::mat4(1.0f), view = glm::mat4(1.0f), projection = glm::mat4(1.0f);

		// Populate the matrices
		{
			float scaleX = 3.0f;
			float scaleY = 3.0f;
			float scaleZ = 3.0f;
			model = glm::scale(model, glm::vec3(scaleX, scaleY, scaleZ));
			view = glm::lookAt(m_cameraPos, m_cameraPos + m_lookDir, m_worldUp);
			projection = glm::perspective(MouseControlledCamera::fov, ((float)s_windowWidth) / s_windowHeight, 0.1f, 100.0f);

			shader->setMat4("model", glm::value_ptr(model));

			shader->setMat4("view", glm::value_ptr(view));
			shader->setMat4("projection", glm::value_ptr(projection));

			shader->setFloat("WorldToObjectScaleX", (float)1.0 / scaleX);
			shader->setFloat("WorldToObjectScaleY", (float)1.0 / scaleY);
			shader->setFloat("WorldToObjectScaleZ", (float)1.0 / scaleZ);
		}

		shader->setFloat("RoomHeight", 1.0);
		shader->setFloat("RoomWidth", 0.5);
		shader->setFloat("RoomDepth", 1.5);
		glBindVertexArray(VAO);
		glDrawElements(GL_TRIANGLES, sizeof(Elements), GL_UNSIGNED_INT, 0);

		// Render a cube for the position of the light. For debugging
		{
			shader2->use();
			shader2->setMat4("model", glm::value_ptr(lightModelMat));
			shader2->setMat4("view", glm::value_ptr(view));
			shader2->setMat4("projection", glm::value_ptr(projection));
			shader2->setVec3("LightColor", lightColor);
		}
		glBindVertexArray(VAO);
		glDrawElements(GL_TRIANGLES, sizeof(Elements), GL_UNSIGNED_INT, 0);

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
	if (glfwGetKey(m_window, GLFW_KEY_SPACE) == GLFW_PRESS && m_lastFrame - m_lastPauseToggle > m_keyPressDurationThreshold) {
		m_pause = !m_pause;
		m_lastPauseToggle = m_lastFrame;
	}
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
