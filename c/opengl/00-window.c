// Tutorial 1 : Opening a window
// http://www.opengl-tutorial.org/beginners-tutorials/tutorial-1-opening-a-window/#how-to-follow-these-tutorials

// gcc 00-window.c -lGL -lGLEW -lglfw && ./a.out

#include <stdio.h>

#include <GL/glew.h>
#include <GLFW/glfw3.h>

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
  // glClearColor(0.0, 0.0, 1.0, 0.0);


  window = glfwCreateWindow(300, 300, "Title", NULL, NULL);
  if (!window) {
    fprintf(stderr, "Failed to open GLFW window.\n");
    glfwTerminate();
    return -1;
  }

  glfwMakeContextCurrent(window);

  // Initialize GLEW
  glewExperimental = GL_TRUE;
  if (glewInit() != GLEW_OK) {
      fprintf(stderr, "Failed to initialize GLEW.\n");
      return -1;
  }

  glClearColor(1.0, 1.0, 1.0, 0.0); // white

  glfwSetInputMode(window, GLFW_STICKY_KEYS, GL_TRUE);

  do {
    glClear(GL_COLOR_BUFFER_BIT);

    draw();

    // Swap buffers
    glfwSwapBuffers(window);
    glfwPollEvents();
   } while (
       glfwGetKey(window, GLFW_KEY_ESCAPE) != GLFW_PRESS
       && glfwWindowShouldClose(window) == 0);


  glfwDestroyWindow(window);

  glfwTerminate();

  return 0;
}
