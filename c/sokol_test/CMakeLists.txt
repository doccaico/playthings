cmake_minimum_required(VERSION 3.0)
project(sokol_test)
set(CMAKE_C_STANDARD 11)
if (CMAKE_SYSTEM_NAME STREQUAL Emscripten)
    set(CMAKE_EXECUTABLE_SUFFIX ".html")
endif()

# Linux -pthread shenanigans
if (CMAKE_SYSTEM_NAME STREQUAL Linux)
    set(THREADS_PREFER_PTHREAD_FLAG ON)
    find_package(Threads REQUIRED)
endif()

#=== LIBRARY: sokol
# add headers to the the file list because they are useful to have in IDEs
set(SOKOL_HEADERS
    sokol/sokol_gfx.h
    sokol/sokol_app.h
    # sokol/sokol_audio.h
    # sokol/sokol_time.h
    sokol/sokol_glue.h)
add_library(sokol STATIC sokol/sokol.c ${SOKOL_HEADERS})
if(CMAKE_SYSTEM_NAME STREQUAL Darwin)
    # compile sokol.c as Objective-C
    target_compile_options(sokol PRIVATE -x objective-c)
    target_link_libraries(sokol
        "-framework QuartzCore"
        "-framework Cocoa"
        "-framework MetalKit"
        "-framework Metal"
        "-framework AudioToolbox")
else()
    if (CMAKE_SYSTEM_NAME STREQUAL Linux)
        target_link_libraries(sokol INTERFACE X11 Xi Xcursor GL asound dl m)
        target_link_libraries(sokol PUBLIC Threads::Threads)
    endif()
endif()
target_include_directories(sokol INTERFACE sokol)

#=== EXECUTABLE: sokol_test
if(CMAKE_SYSTEM_NAME STREQUAL Windows)
    add_executable(sokol_test WIN32 sokol_test.c)
else()
    add_executable(sokol_test sokol_test.c)
endif()
target_link_libraries(sokol_test sokol)
if (CMAKE_SYSTEM_NAME STREQUAL Emscripten)
    target_link_options(sokol_test PUBLIC --shell-file ../sokol/shell.html)
    target_link_options(sokol_test PUBLIC -sNO_FILESYSTEM=1 -sASSERTIONS=0 -sMALLOC=emmalloc --closure=1)
endif()

# explicitly strip dead code
if (CMAKE_C_COMPILER_ID MATCHES "Clang" AND NOT CMAKE_SYSTEM_NAME STREQUAL Emscripten)
    target_link_options(sokol_test PRIVATE LINKER:-dead_strip)
endif()
