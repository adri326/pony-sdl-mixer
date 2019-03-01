use "path:../build"
use "lib:pony_sdl_mixer_c"
use "../sdl2"
use ".."
use "time"

actor Main
  new create(env: Env) =>
    try SDL.init([SDLInitAudio])?
      FMix.init(0x10)?
      env.out.print("Hello world! 🐺")
      FMix.open_audio((44100, 256), 2)?
      let chunk = FMix.read("../resources/sound.ogg")?
      if not FMix.play(chunk) then error end
      Timers()(Timer(Notify, 2_000_000_000))
    else env.out.print("Error: " + SDL.get_error())
    end

class Notify is TimerNotify
  fun apply(timer: Timer, count: U64): Bool => false
