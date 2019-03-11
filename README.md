# pony-sdl-mixer

Music, in [Pony](https://www.ponylang.io/)!
Using `SDL2` and `SDL_mixer`, and a C wrapper to "flatten" stuff and make it easier for Pony to access the different things.

All of the classes and methods are prefixed with `FMix`.

## How to install & build

*This library depends on `SDL2` and `SDL_mixer`; you will have to install them if you didn't already.*

First, you will have to clone this repository from github:

```sh
git clone https://github.com/adri326/pony-sdl-mixer
cd pony-sdl-mixer
git submodule update --init
```

Alternatively, you can add it as a git submodule:

```sh
git submodule add https://github.com/adri326/pony-sdl-mixer
git submodule update --init --recursive
```

If you are adding this library to your own project, you should create a `CMakeLists.txt` file at its root, and include in it `pony-sdl-mixer`:

```cmake
cmake_minimum_required(VERSION 3.13)

# this is the only line you need to add if you already have a cmake project set up
include(pony-sdl-mixer/include.cmake)

set(PONY_PATH $ENV{PONY_PATH}:${PROJECT_SOURCE_DIR}/pony-sdl-mixer:${PROJECT_SOURCE_DIR}/build)

add_custom_target(
  your-project-name ALL
  COMMAND ponyc -o build --path ${PONY_PATH}
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  DEPENDS pony_sdl_mixer_c
)
```

`pony-sdl-mixer` can simply be added to your project using:

```pony
use "pony-sdl-mixer"
```

Once this is done, you should create a `build` directory in your project, in which `FMix`'s dependency, `pony_sdl_mixer_c`, will be built.
Inside of your `build` directory, you may build your project.

```sh
mkdir build
cd build
cmake ..

# run whenever you want to build
make
```

You should now have `pony-sdl-mixer` configured in your project, and ready to use!
Anyone cloning your project will only have to run `git submodule update --init --recursive` and the last step to build it.

## Tests

The differents tests have their own `make` rule:

```sh
make test.basic && test/basic
make test.listener && test/listener
```

## Usage

Here's an example program using `pony-sdl-mixer`:

```pony
use "pony-sdl-mixer"
use "time"

actor Main
  new create(env: Env) =>
    try
      FMix.init_sdl()?
      FMix.init()?
      FMix.open_audio((44100, 256), 2)?

      match FMix.read_chunk("path/to/file.ogg") // OPUS files are sparsely supported
      | let chunk: FMixChunk => chunk.play()
        let timers = Timers()
        timers(Timer(Notify, 10_000_000_000)) // wait 10 seconds before closing
      else error
      end

    else env.out.print("Error! " + FMix.get_error())
    end

class Notify is TimerNotify
  fun ref apply(timer: Timer, count: U64) =>
    FMix.close_audio()
    FMix.quit()
    false
```
