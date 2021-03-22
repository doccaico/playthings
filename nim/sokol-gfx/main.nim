import nimgl/[glfw]
import ./gfx

assert glfwInit()

glfwWindowHint(GLFWContextVersionMajor, 3)
glfwWindowHint(GLFWContextVersionMinor, 3)
glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
glfwWindowHint(GLFWResizable, GLFW_FALSE)

let win = glfwCreateWindow(640, 480)
makeContextCurrent(win)

var desc = sg_desc()
sg_setup(addr(desc))

var clearColors {.noInit.}:array[SG_MAX_COLOR_ATTACHMENTS, sg_color_attachment_action]
clearColors[0] = sg_color_attachment_action(action: SG_ACTION_CLEAR, value: sg_color(r: 1.0f, g: 0.0f, b: 0.0f, a: 1.0f))

var pass_action = sg_pass_action(colors: clearColors)

while not windowShouldClose(win):

    var g = (pass_action.colors[0].value.g + 0.01f)
    if g > 1.0f: g = 0.0f
    pass_action.colors[0].value.g = g;

    var w, h: cint
    getFramebufferSize(win, addr(w), addr(h))
    sg_begin_default_pass(addr(pass_action), w, h)
    sg_end_pass()
    sg_commit()
    glfwPollEvents()
    swapBuffers(win)

sg_shutdown()
glfwTerminate()
