use "path:../build"
use "lib:pony_sdl_mixer_c"
use "debug"

primitive FMix
  fun init(flags: (Array[FMixInitFlag] | FMixInitFlag | I32))? =>
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
    var major = I32(0)
    var minor = I32(0)
    var patch = I32(0)
    @FMix_LinkedVersion[None](addressof major, addressof minor, addressof patch)
    (major, minor, patch)

  fun compiled_version(): (I32, I32, I32) =>
    var major = I32(0)
    var minor = I32(0)
    var patch = I32(0)
    @FMix_CompiledVersion[None](addressof major, addressof minor, addressof patch)
    (major, minor, patch)

  fun open_audio(freq: (I32, I32), channels: I32)? =>
    if @FMix_OpenAudio[I32](freq._1, freq._2, U16(0), channels) == -1 then error end

  fun close_audio() =>
    @FMix_CloseAudio[None]()

  fun allocate_channels(n: I32): Bool =>
    let res = @FMix_AllocateChannels[I32](n) == 0
    res

  fun allocated_channels(): I32 =>
    @FMix_AllocatedChannels[I32]()

  fun set_volume(channel: I32, volume: I32): Bool =>
    if (channel == -1) or (channel < allocated_channels()) then
      @FMix_SetVolume[I32](channel, volume)
      true
    else false end

  fun get_volume(channel: I32 = -1): I32 =>
    @FMix_GetVolume[I32](channel)

  fun query_spec(): (FMixQuerySpec | None) =>
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

  fun read(file: String): (FMixChunk | None) =>
    let chunk = @FMix_Read[MixChunkRaw](file.cpointer())
    if not chunk.is_null() then FMixChunk(chunk) end

  fun play(chunk: FMixChunk): Bool =>
    let res = @FMix_Play[I32](chunk._get_raw()) == 0
    res

  fun quit(): I32 =>
    let res = @FMix_Quit[I32]()
    res

  fun is_played(chunk: MixChunkRaw box): Bool =>
    var n = I32(0)
    let length = allocated_channels()
    while n < length do
      if @FMix_GetChunkStatic[MixChunkRaw](n) == chunk then
        return true
      end
      n = n + 1
    end
    false

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

type FMixInitFlag is (FMixInitFLAC | FMixInitMOD | FMixInitMP3 | FMixInitOGG | FMixInitMID | FMixInitOPUS)

class FMixQuerySpec
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
  let _raw: MixChunkRaw ref
  new create(raw: MixChunkRaw ref) =>
    _raw = consume raw

  fun ref _get_raw(): MixChunkRaw ref =>
    _raw

  fun set_volume(volume: I32) =>
    @FMix_SetChunkVolume[None](_raw, volume)

  fun get_volume(): I32 =>
    @FMix_GetChunkVolume[I32](_raw)

  fun _final() =>
    @FMix_FreeChunk[None](_raw)
