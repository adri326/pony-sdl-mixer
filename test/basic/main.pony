use "../../pony-sdl-mixer"
use "time"

actor Main
  let env: Env

  new create(env': Env) =>
    env = env'
    try
      FMix.init_sdl()?
      FMix.init()?
      FMix.open_audio((44100, 512), 2)?
      next()
    else
      env.out.print("Error: " + FMix.get_error())
    end

  fun ref next() =>
    match FMix.read_chunk("../resources/sound.ogg")
    | let chunk: FMixChunk =>
      chunk.play()
      Timers()(Timer(Notify, 100_000_000, 100_000_000))
    else env.out.print("Error reading file!")
    end

class Notify is TimerNotify
  fun ref apply(timer: Timer, count: U64): Bool =>
    FMix.channels_playing() != 0
