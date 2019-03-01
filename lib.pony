primitive MixChunkRaw
type MixChunk is Pointer[MixChunkRaw]

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
    if @FMix_Init[I32](flags) == -1 then error end

  fun open_audio(freq: (I32, I32), channels: I32)? =>
    if @FMix_OpenAudio[I32](freq._1, freq._2, U16(0), channels) == -1 then error end

  fun read(file: String): MixChunk? =>
    let chunk = @FMix_Read[MixChunk](file.cpointer())
    if chunk.is_null() then error end
    chunk

  fun play(chunk: MixChunk): Bool =>
    @FMix_Play[I32](chunk) == 0

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
