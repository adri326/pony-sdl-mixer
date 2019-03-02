#ifndef FLATTEN_H
#define FLATTEN_H

#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>
#include <stdbool.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include <SDL2/SDL_audio.h>

struct FMix_Status {
  Mix_Chunk* chunk;
  bool playing;
  bool garbage;
};

typedef struct FMix_Status FMix_Status;

#define FMIX_ERR_INVALID_CHUNK (0x40000001)

int32_t FMix_Init(int32_t flags);
int32_t FMix_Quit();
void _FMix_UpdateStaticChunksLength();

void FMix_CompiledVersion(int32_t* major, int32_t* minor, int32_t* patch);
void FMix_LinkedVersion(int32_t* major, int32_t* minor, int32_t* patch);

int32_t FMix_OpenAudio(int32_t freq, int32_t chunksize, uint16_t format, int32_t channels);
Mix_Chunk* FMix_Read(char* file);
int32_t FMix_Play(Mix_Chunk* chunk, int32_t channel);

int32_t FMix_AllocateChannels(int32_t n);
int32_t FMix_AllocatedChannels();
int32_t FMix_SetVolume(int32_t channel, int32_t volume);
int32_t FMix_GetVolume(int32_t channel);

void FMix_SetChunkVolume(Mix_Chunk* chunk, int32_t volume);
int32_t FMix_GetChunkVolume(Mix_Chunk* chunk);
Mix_Chunk* FMix_GetChunk(int32_t channel);
Mix_Chunk* FMix_GetChunkStatic(int32_t channel);
void FMix_FreeChunk(Mix_Chunk* chunk);

static void _FMix_ChannelHandler(int channel);

#endif
