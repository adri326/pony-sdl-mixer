use "../../pony-sdl-mixer"
use "../../sdl2"
use "time"

actor Main
  let env: Env

  new create(env': Env) =>
    env = env'
    try
      SDL.init([SDLInitAudio])?
      FMix.init()?
      FMix.open_audio((44100, 512), 2)?
      next()
    else
      env.out.print("Error: " + SDL.get_error())
    end

  fun ref next() =>
    match recover val FMix.read_chunk("../resources/sound.ogg") end
    | let chunk: FMixChunk val =>
      chunk.play()
      let handler = FMixEventHandler()
      handler(Listener(env, chunk))
    else env.out.print("Error reading file!")
    end

class Listener is FMixListener
  let env: Env
  let chunk: FMixChunk val
  var n: I32 = 0
  let max_n: I32 = 1

  new iso create(env': Env, chunk': FMixChunk val) =>
    env = env'
    chunk = chunk'

  fun ref apply(event: FMixEventHelper val) =>
    if FMix.channels_playing() == 0 then
      if n < max_n then
        n = n + 1
        env.out.print("Playing your sound again")
        chunk.play()
      else
        env.out.print("Done playing!")
        event.handler.stop()
      end
    end
