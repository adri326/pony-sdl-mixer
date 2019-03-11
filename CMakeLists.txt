cmake_minimum_required(VERSION 3.13)
project(pony_sdl_mixer_c VERSION 0.0.2 DESCRIPTION "Flattening out the SDL_mixer stuff, making it accessible to pony")

include(include.cmake)

file(MAKE_DIRECTORY test)

add_custom_target(test.basic
  ponyc ../test/basic -o test;
  DEPENDS pony_sdl_mixer_c
)
add_custom_target(test.listener
  ponyc ../test/listener -o test;
  DEPENDS pony_sdl_mixer_c
)
