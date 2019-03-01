# pony-sdl-mixer

Music, in [Pony](https://www.ponylang.io/)!
Using `SDL2` and `SDL_mixer`, and a C wrapper to "flatten" stuff and make it easier for Pony to access the different things.

## How to install & build

```sh
git clone https://github.com/adri326/pony-sdl-mixer
cd pony-sdl-mixer
git submodule update --init
mkdir build
cmake ..
make && make test && ./test
```

That's a lot, I'll make it clearer later.
You would now be listening to a small, test sound (that I made with VCV Rack).
