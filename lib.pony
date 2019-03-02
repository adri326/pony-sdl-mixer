use "path:../build"
use "lib:pony_sdl_mixer_c"
use "debug"

primitive FMix
  """
  Where you will find almost everything you need. Most of the features are found here.

  To start off, you will need to call `SDL.init(...)` and `FMix.init(...)`. If you do not have `pony-sdl2`, you can get it [here](https://github.com/adri326/pony-sdl2).
  These two functions will load the different modules. You will then have to open the audio interface using `FMix.open_audio((frequency, buffer_size), channels)`.

  Once your program is done, you should first close the audio interface, then quit FMix (optionally also quit SDL2).

  ```pony
actor Main
  new create(env: Env) =>
    try
      SDL.init([SDLInitAudio])?
      FMix.init()?
      FMix.open_audio((44100, 256), 2)?

      // here goes your code using FMix

      let timers = Timers()
      timers(Timer(Notify, 10_000_000_000)) // wait 10 seconds before closing

    else env.out.print("Error! " + SDL.get_error())
    end

class Notify is TimerNotify
  fun ref apply(timer: Timer, count: U64) =>
    FMix.close_audio()
    FMix.quit()
    false
  ```
  """
  fun init(flags: (Array[FMixInitFlag] | FMixInitFlag | I32) = 0x58)? =>
    """
    Initialises the SDL_mixer module: this loads different submodules (OGG, MP3, etc) based on the flags given.
    If a submodules is not loaded, FMix will fail loading files which require this submodule.

    By default, the OGG, MP3 and OPUS submodules are loaded.
    """
    let flags' = match flags
    | let arr: Array[FMixInitFlag] =>
      var res: I32 = 0
      for flag in arr.values() do
        res = res or flag()
      end
      res
    | let flag: FMixInitFlag => flag()
    | let flags'': I32 => flags''
    end
    if @FMix_Init[I32](flags) == -1 then
      error
    end

  fun linked_version(): (I32, I32, I32) =>
    """
    Returns the linked version, that is, the library used when *running* the code.
    """
    var major = I32(0)
    var minor = I32(0)
    var patch = I32(0)
    @FMix_LinkedVersion[None](addressof major, addressof minor, addressof patch)
    (major, minor, patch)

  fun compiled_version(): (I32, I32, I32) =>
    """
    Returns the linked version, that is, the library used when *compiling* the code.
    """
    var major = I32(0)
    var minor = I32(0)
    var patch = I32(0)
    @FMix_CompiledVersion[None](addressof major, addressof minor, addressof patch)
    (major, minor, patch)

  fun open_audio(freq: (I32, I32), channels: I32)? =>
    """
    Opens the audio interface. `freq` is a tuple containing the frequency (in Hz) and the buffer size.
    For games, it is recommended to use a frequency of 22050 Hz, to prevent draining too much resources on slower machines.

    The buffer size depends on your use. For music, you could go for a bigger one (4096); for game sounds, a smaller one could fit better (256).
    Try stuff out!
    """
    if @FMix_OpenAudio[I32](freq._1, freq._2, U16(0), channels) == -1 then error end

  fun close_audio() =>
    """
    Does the opposite of the `open_audio` method. It is recommended to do that once you do not need the audio interface anymore.
    """
    @FMix_CloseAudio[None]()

  fun allocate_channels(n: I32): Bool =>
    """
    Allocates `n` *mixer* channels. These are different from *output* channels.
    You are not limited to the number of output channels.
    """
    @FMix_AllocateChannels[I32](n) == 0

  fun allocated_channels(): I32 =>
    """
    Returns you the number of allocated *mixer* channels.
    """
    @FMix_AllocatedChannels[I32]()

  fun channels_playing(): I32 =>
    """
    Tells you how many *mixer* channels are playing
    """
    @FMix_Playing[I32](I32(-1))

  fun channel_playing(channel: I32): Bool =>
    """
    Tells you whether or not a particular *mixer* channel is playing.
    """
    @FMix_Playing[I32](channel) == 1

  fun set_volume(channel: (I32 | FMixAny), volume: I32): Bool =>
    """
    Sets the volume for a *mixer* channel. `volume` varies from `0` to `128`.
    Values outside this range will be minimized or maximized.

    If `channel` is `FMixAny`, all the channels will have their volumes set to the given value.
    """
    let channel' = match channel
    | let x: I32 => x
    | FMixAny => -1
    end
    if (channel' == -1) or (channel' < allocated_channels()) then
      @FMix_SetVolume[I32](channel', volume)
      true
    else false end

  fun get_volume(channel: (I32 | FMixAny) = FMixAny): I32 =>
    """
    Returns the volume of a *mixer* channel (or all the channels if `channel` is `FMixAny`)
    """
    @FMix_GetVolume[I32](
      match channel
      | let x: I32 => x
      | FMixAny => -1
      end
    )

  fun query_spec(): (FMixQuerySpec | None) =>
    """
    Returns you the specs of the oppened audio interface.
    """
    var frequency = I32(0)
    var format = U16(0)
    var channels = I32(0)
    var consecutive_opens = I32(0)
    let res = @FMix_QuerySpec[I32](addressof frequency, addressof format, addressof channels, addressof consecutive_opens)
    if res == 0 then
      FMixQuerySpec(frequency, format, channels, consecutive_opens)
    else
      None
    end

  fun read_chunk(file: String): (FMixChunk ref | None) =>
    """
    Reads a file as a FMixChunk
    """
    let chunk = @FMix_Read[MixChunkRaw](file.cpointer())
    if not chunk.is_null() then FMixChunk(chunk) end

  fun quit(): I32 =>
    """
    Closes the different submodules. It does more, as specified [here](https://www.libsdl.org/projects/SDL_mixer/docs/SDL_mixer.html#SEC10)
    """
    @FMix_Quit[I32]()

primitive FMixErrInvalidChunk
  fun apply(): I32 => 0x40000001

primitive FMixInitFLAC
  fun apply(): I32 => 0x00000001
primitive FMixInitMOD
  fun apply(): I32 => 0x00000002
primitive FMixInitMP3
  fun apply(): I32 => 0x00000008
primitive FMixInitOGG
  fun apply(): I32 => 0x00000010
primitive FMixInitMID
  fun apply(): I32 => 0x00000020
primitive FMixInitOPUS
  fun apply(): I32 => 0x00000040

primitive FMixAny

type FMixInitFlag is (FMixInitFLAC | FMixInitMOD | FMixInitMP3 | FMixInitOGG | FMixInitMID | FMixInitOPUS)

class FMixQuerySpec
  """
  The specifications of the oppened audio interface: frequency, format, channels and how many times has it been open in the program.
  This behavior comes from the fact that you can [open an audio interface several times](https://www.libsdl.org/projects/SDL_mixer/docs/SDL_mixer.html#SEC11).
  """
  let frequency: I32
  let format: U16
  let channels: I32
  let consecutive_opens: I32

  new create(frequency': I32, format': U16, channels': I32, consecutive_opens': I32) =>
    frequency = frequency'
    format = format'
    channels = channels'
    consecutive_opens = consecutive_opens'

primitive _MixChunkRaw
type MixChunkRaw is Pointer[_MixChunkRaw]

class FMixChunk
  """
  A slice of sound. This is a wrapper around the internal Mix_Chunk type.
  """
  let _raw: MixChunkRaw ref
  new create(raw: MixChunkRaw ref) =>
    _raw = consume raw

  fun ref set_volume(volume: I32) =>
    """
    Sets the volume for this chunk. `volume` varies from 0 to 128, and will be minimized/maximized if needed.
    """
    @FMix_SetChunkVolume[None](_raw, volume)

  fun get_volume(): I32 =>
    """
    The volume of this chunk.
    """
    @FMix_GetChunkVolume[I32](_raw)

  fun play(channel: (I32 | FMixAny) = FMixAny): Bool =>
    """
    Plays the chunk in a *mixer* channel (or any).
    """
    let channel' = match channel
    | let n: I32 => n
    | FMixAny => I32(-1)
    end
    if channel' < -1 then
      false
    else
      @FMix_Play[I32](_raw, channel') == 0
    end

  fun is_played(): Bool =>
    """
    Whether or not the chunk is being played in any *mixer* channel.
    """
    var n = I32(0)
    let length = FMix.allocated_channels()
    while n < length do
      if (@FMix_GetChunkStatic[MixChunkRaw](n) == _raw) and (@FMix_IsChannelPlaying[I8](n) == 1) then
        return true
      end
      n = n + 1
    end
    false

  fun _final() =>
    """
    **Note:** this will only free the raw `Mix_Chunk` once it is finished playing on every channel.
    This uses a C, purposely-designed garbage collector, which listens on channel finish events and checks for garbage chunks.
    """
    @FMix_FreeChunk[None](_raw)
