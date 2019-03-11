use "../../pony-sdl-mixer"
use "../../sdl2"

actor Main
  let env: Env

  new create(env': Env) =>
    """
    Here we initialize SDL and FMix
    """
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
    """
    Called once everything has been initialized
    """
    match recover val FMix.read_chunk("../resources/sound.ogg") end
    | let chunk: FMixChunk val =>
      chunk.play()
      let handler = FMixEventHandler
      handler(Listener(env, chunk))
    else env.out.print("Error reading file!")
    end

class Listener is FMixListener
  """
  This class will be used to listen for the events
  """

  let env: Env
  let chunk: FMixChunk val
  var n: I32 = 0
  let max_n: I32 = 1

  new iso create(env': Env, chunk': FMixChunk val) =>
    env = env'
    chunk = chunk'

  fun ref apply(event: FMixEventHelper val) =>
    // check if the kind of event is what we are looking for: channel finished events
    if event.kind is FMixEventChannelFinished then
      if FMix.channels_playing() == 0 then
        if n < max_n then
          n = n + 1
          env.out.print("Playing your sound again")
          chunk.play()
        else
          env.out.print("Done playing!")
          event.handler.dispose()
        end
      end
    end
