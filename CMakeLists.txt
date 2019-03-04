cmake_minimum_required(VERSION 3.13)
project(pony_sdl_mixer_c VERSION 0.0.1 DESCRIPTION "Flattening out the SDL_mixer stuff, making it accessible to pony")

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

find_package(SDL2 REQUIRED)
find_package(SDL2_mixer REQUIRED)
include_directories(${SDL2_INCLUDE_DIRS} ${SDL2_MIXER_INCLUDE_DIRS})

set(HEADER_FILES src/flatten.h)
set(SOURCE_FILES src/flatten.c)
add_library(pony_sdl_mixer_c SHARED ${HEADER_FILES} ${SOURCE_FILES})

target_link_libraries(pony_sdl_mixer_c PRIVATE ${SDL2_LIBRARIES} ${SDL2_MIXER_LIBRARIES})

install(
  TARGETS pony_sdl_mixer_c
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  PUBLIC_HEADER DESTINATION include
  INCLUDES DESTINATION include
)

file(MAKE_DIRECTORY test)

add_custom_target(test.basic
  ponyc ../test/basic -o test;
  DEPENDS pony_sdl_mixer_c
)
add_custom_target(test.listener
  ponyc ../test/listener -o test;
  DEPENDS pony_sdl_mixer_c
)
