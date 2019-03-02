use "path:../build"
use "lib:pony_sdl_mixer_c"
use "../sdl2"
use ".."
use "time"

actor Main
  new create(env: Env) =>
    log_versions(env)
    let nonce = I32(1)
    try
      // we init our stuff!
      SDL.init([SDLInitAudio])?
      FMix.init([FMixInitOGG])?
      FMix.open_audio((44100, 256), 2)?
      FMix.allocate_channels(100) // we'll need a lot of them! They're very cheap anyways

      // just some logging, for the sake of it
      match FMix.query_spec()
      | let specs': FMixQuerySpec => env.out.print(
        "Allocated "
        + specs'.channels.string()
        + " channels at "
        + specs'.frequency.string()
        + "Hz\n")
      end

      // Let's load your file! 🐺

      match recover val FMix.read_chunk("../resources/sound.ogg") end
      | let chunk': FMixChunk val =>
        let notifier = Notify(chunk', nonce)
        Timers()(Timer(consume notifier, 150_000_000, 150_000_000))
      else env.out.print("Oops")
      end
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
  var times: I32 = 0
  let chunk: FMixChunk val
  let nonce: I32

  new iso create(chunk': FMixChunk val, nonce': I32) =>
    chunk = chunk'
    nonce = nonce'

  fun ref apply(timer: Timer, count: U64): Bool =>
    times = times + 1
    if times > nonce then
      if chunk.is_played() then
        true
      else
        FMix.close_audio()
        FMix.quit()
        false
      end
    else
      chunk.play()
      true
    end
