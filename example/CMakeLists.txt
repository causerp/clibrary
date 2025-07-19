cmake_minimum_required(VERSION 3.22)

project(clib LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED True)

if (MSVC)
    set(CMAKE_IMPORT_LIBRARY_PREFIX "lib")
    set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
endif()

add_library(clib clib.c)

install(TARGETS clib LIBRARY DESTINATION .)
