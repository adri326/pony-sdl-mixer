cmake_minimum_required(VERSION 3.13)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

find_package(SDL2 REQUIRED)
find_package(SDL2_mixer REQUIRED)

include_directories(${SDL2_INCLUDE_DIRS} ${SDL2_MIXER_INCLUDE_DIRS} ${PONYRT_LIBRARIES})

find_library(PONYRT ponyrt)

set(HEADER_FILES src/flatten.h)
set(SOURCE_FILES src/flatten.c)

add_library(pony_sdl_mixer_c SHARED ${HEADER_FILES} ${SOURCE_FILES})

target_link_libraries(pony_sdl_mixer_c PRIVATE ${SDL2_LIBRARIES} ${SDL2_MIXER_LIBRARIES} ${PONYRT_LIBRARIES})

install(
  TARGETS pony_sdl_mixer_c
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  PUBLIC_HEADER DESTINATION include
  INCLUDES DESTINATION include
)
