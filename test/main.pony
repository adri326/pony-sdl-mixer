use "path:../build"
use "lib:pony_sdl_mixer_c"
use "../sdl2"
use ".."
use "time"

actor Main
  new create(env: Env) =>
    log_versions(env)
    try
      SDL.init([SDLInitAudio])?
      FMix.init(0x10)?

      FMix.open_audio((44100, 256), 2)?
      let specs = FMix.query_spec()
      match specs
      | let specs': FMixQuerySpec => env.out.print(
        "Allocated "
        + specs'.channels.string()
        + " channels at "
        + specs'.frequency.string()
        + "Hz\n")
      end

      env.out.print("Let's load your file! 🐺")
      let chunk = FMix.read("../resources/sound.ogg")
      match chunk
      | let chunk': FMixChunk =>
        env.out.print("Successfully loaded it, so let's play it! 🦊")
        if not FMix.play(chunk') then error end
        chunk'.final()
      else error
      end

      // env.out.print(FMix.set_volume(32, 128).string())

      Timers()(Timer(Notify, 15_000_000_000))
    else env.out.print("Error: " + SDL.get_error())
    end

  fun log_versions(env: Env) =>
    let sdl_version = SDL.version()
    let fmix_linked_version = FMix.linked_version()
    let fmix_compiled_version = FMix.compiled_version()
    env.out.print("Running SDL version "
      + sdl_version._1.string()
      + "." + sdl_version._2.string()
      + "." + sdl_version._3.string()
    )
    env.out.print("Running SDL_mixer, linked version: "
      + fmix_linked_version._1.string()
      + "." + fmix_linked_version._2.string()
      + "." + fmix_linked_version._3.string()
      + "; compiled version: "
      + fmix_compiled_version._1.string()
      + "." + fmix_compiled_version._2.string()
      + "." + fmix_compiled_version._3.string()
    )

class Notify is TimerNotify
  fun apply(timer: Timer, count: U64): Bool => false
    FMix.close_audio()
    FMix.quit()
    false
