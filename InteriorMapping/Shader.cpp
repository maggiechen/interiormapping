#include "Shader.h"

Shader::Shader(const char* vertexPath, const char* fragmentPath)
{
	std::string vertexCode;
	std::string fragmentCode;

	std::ifstream vShaderFile;
	std::ifstream fShaderFile;

	// allow the input file streams to throw exceptions 
	// failbit is for errors that don't necessarily mean further operations will fail
	// badbit is for errors that do
	vShaderFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);
	fShaderFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);
	try
	{
		vShaderFile.open(vertexPath);
		fShaderFile.open(fragmentPath);
		std::stringstream vShaderStream, fShaderStream;
		vShaderStream << vShaderFile.rdbuf(); // rdbuf gives pointer to the buffer object associated w/ the stream
		fShaderStream << fShaderFile.rdbuf();
		vShaderFile.close();
		fShaderFile.close();
		vertexCode = vShaderStream.str();
		fragmentCode = fShaderStream.str();
	}
	catch(std::ifstream::failure e)
	{
		std::cout << "ERROR::SHADER::FILE_NOT_SUCCESSFULLY_READ" << e.what() << std::endl;
	}

	const char* vShaderCode = vertexCode.c_str();
	const char* fShaderCode = fragmentCode.c_str();
	
	unsigned int vertex, fragment;
	int success;
	char infoLog[512];

	vertex = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vertex, 1, &vShaderCode, NULL);
	glCompileShader(vertex);
	glGetShaderiv(vertex, GL_COMPILE_STATUS, &success);
	if (!success)
	{
		glGetShaderInfoLog(vertex, 512, NULL, infoLog);
		std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
	};
	
	fragment = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragment, 1, &fShaderCode, NULL);
    glCompileShader(fragment);
    glGetShaderiv(fragment, GL_COMPILE_STATUS, &success);
    if (!success)
    {
        glGetShaderInfoLog(fragment, 512, NULL, infoLog);
        std::cout << "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n" << infoLog << std::endl;
    };

	ID = glCreateProgram();
	glAttachShader(ID, vertex);
	glAttachShader(ID, fragment);
	glLinkProgram(ID);
	if (!success)
	{
		glGetProgramInfoLog(ID, 512, NULL, infoLog);
		std::cout << "ERROR:SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;
	}

	glDeleteShader(vertex);
	glDeleteShader(fragment);
	
}

void Shader::use()
{
	glUseProgram(ID);
}

void Shader::setBool(const std::string& name, bool value) const
{
	// this thing will return -1 if the uniform is optimized away or you spelt it incorrectly
	int loc = glGetUniformLocation(ID, name.c_str());

	glUniform1i(loc, (int) value); // I guess there's no uniform set for bool, you just have to use int?
}

void Shader::setInt(const std::string& name, int value) const
{
	int loc = glGetUniformLocation(ID, name.c_str());
	glUniform1i(loc, value);
}

void Shader::setFloat(const std::string& name, float value) const
{
	int loc = glGetUniformLocation(ID, name.c_str());
	glUniform1f(loc, value);
}

void Shader::setFloat2(const std::string& name, float value1, float value2)
{
	int loc = glGetUniformLocation(ID, name.c_str());
	glUniform2f(loc, value1, value2);
}

void Shader::setFloat4(const std::string& name, float value1, float value2, float value3, float value4)
{
	int loc = glGetUniformLocation(ID, name.c_str());
	glUniform4f(loc, value1, value2, value3, value4);
}

void Shader::setMat4(const std::string& name, const GLfloat* matrix)
{
	unsigned int loc = glGetUniformLocation(ID, name.c_str());
	glUniformMatrix4fv(loc, 1, GL_FALSE, matrix);
}
