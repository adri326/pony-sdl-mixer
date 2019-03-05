# pony-sdl-mixer

Music, in [Pony](https://www.ponylang.io/)!
Using `SDL2` and `SDL_mixer`, and a C wrapper to "flatten" stuff and make it easier for Pony to access the different things.

## How to install & build

```sh
# installation
git clone https://github.com/adri326/pony-sdl-mixer
cd pony-sdl-mixer
git submodule update --init

# create a build directory, go in it and compile
mkdir build
cd build
cmake ..
make

# run basic test:
make test.basic && test/basic

# run listener test:
make test.listener && test/listener
```

That's a lot, I'll make it clearer later.
You would now be listening to a small, test sound (that I made with VCV Rack).
