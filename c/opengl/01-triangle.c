// "Hello Triangle" OpenGL 4 Up and Running
// https://antongerdelan.net/opengl/hellotriangle.html
// gcc 01-triangle.c -lGL -lGLEW -lglfw && ./a.out

#include <stdio.h>
#include <stdlib.h>

#include <GL/glew.h>
#include <GLFW/glfw3.h>

void print_version_info(void) {
  // Renderer: Mesa Intel(R) UHD Graphics 630 (CML GT2)
  // OpenGL version supported 4.6 (Core Profile) Mesa 20.2.6
  const GLubyte* renderer = glGetString(GL_RENDERER);
  const GLubyte* version = glGetString(GL_VERSION);
  printf("Renderer: %s\n", renderer);
  printf("OpenGL version supported %s\n", version);
}

void compile(GLuint shader) {

  glCompileShader(shader);

  GLint status;
  glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
  
  if (status == GL_FALSE) {
    GLint bufSize;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &bufSize);

    GLchar *buf = (GLchar*)malloc(bufSize);
    glGetShaderInfoLog(shader, bufSize, NULL, buf);
    fprintf(stderr, "%s\n", buf);
    free(buf);
  }
}

void draw(void) { }

GLFWwindow *window;

int main(int argc, char *argv[]) {

  // Initialise GLFW
  glewExperimental = GL_TRUE; // Needed for core profile
  if(!glfwInit()) {
    fprintf(stderr, "Failed to initialize GLFW\n");
    return -1;
  }

  glfwWindowHint(GLFW_SAMPLES, 4); // 4x antialiasing
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // To make MacOS happy; should not be needed
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  window = glfwCreateWindow(1024, 768, "Title", NULL, NULL);
  if (!window) {
    fprintf(stderr, "Failed to open GLFW window.\n");
    glfwTerminate();
    return -1;
  }
  glfwMakeContextCurrent(window);

  print_version_info();

  // Initialize GLEW
  glewExperimental = GL_TRUE;
  if (glewInit() != GLEW_OK) {
      fprintf(stderr, "Failed to initialize GLEW.\n");
      return -1;
  }

  glfwSetInputMode(window, GLFW_STICKY_KEYS, GL_TRUE);
  // glClearColor(1.0f, 1.0f, 1.0f, 0.0f); // white
  glClearColor(0.0f, 0.0f, 0.4f, 0.0f); // dark blue

  float points[] = {
    0.0f,  0.5f,  0.0f,
    0.5f, -0.5f,  0.0f,
    -0.5f, -0.5f,  0.0f
  };

  GLuint vbo = 0;
  glGenBuffers(1, &vbo);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glBufferData(GL_ARRAY_BUFFER, 9 * sizeof(float), points, GL_STATIC_DRAW);

  GLuint vao = 0;
  glGenVertexArrays(1, &vao);
  glBindVertexArray(vao);
  glEnableVertexAttribArray(0);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);

  const char* vertex_shader =
    "#version 400\n"
    "in vec3 vp;"
    "void main() {"
    "  gl_Position = vec4(vp, 1.0);"
    "}";

  const char* fragment_shader =
    "#version 400\n"
    "out vec4 frag_colour;"
    "void main() {"
    "  frag_colour = vec4(0.5, 0.0, 0.5, 1.0);"
    "}";

  GLuint vs = glCreateShader(GL_VERTEX_SHADER);
  glShaderSource(vs, 1, &vertex_shader, NULL);
  compile(vs);

  GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(fs, 1, &fragment_shader, NULL);
  compile(fs);

  GLuint shader_programme = glCreateProgram();
  glAttachShader(shader_programme, fs);
  glAttachShader(shader_programme, vs);
  glLinkProgram(shader_programme);

  // main loop
  do {
    glClear(GL_COLOR_BUFFER_BIT);

    glUseProgram(shader_programme);
    glBindVertexArray(vao);
    glDrawArrays(GL_TRIANGLES, 0, 3);

    // Swap buffers
    glfwSwapBuffers(window);
    glfwPollEvents();
   } while (
       glfwGetKey(window, GLFW_KEY_ESCAPE) != GLFW_PRESS
       && glfwWindowShouldClose(window) == 0);

  // glfwDestroyWindow(window);
  glfwTerminate();

  return 0;
}
