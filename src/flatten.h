#ifndef FLATTEN_H
#define FLATTEN_H

#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>
#include <stdbool.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include <SDL2/SDL_audio.h>
#include <pony.h>

struct FMix_Status {
  Mix_Chunk* chunk;
  bool playing;
  bool garbage;
};

typedef struct FMix_Status FMix_Status;

typedef void FMix_EventHandler;


#define FMIX_ERR_INVALID_CHUNK (0x40000001)
#define FMIX_EVENT_NULL -1
#define FMIX_EVENT_CHANNEL_FINISHED 1

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

int32_t FMix_GetChunkLength(Mix_Chunk* chunk);
void FMix_CreateEvent(int32_t channel, int32_t kind);
void FMix_RegisterEventHandler(void* handler);
void FMix_DestroyHandler(void* handler);
void FMix_DispatchEvent(int32_t channel, int32_t kind);

#endif
