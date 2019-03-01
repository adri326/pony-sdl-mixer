#ifndef FLATTEN_H
#define FLATTEN_H

#include <stdlib.h>
#include <inttypes.h>
#include <stdio.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include <SDL2/SDL_audio.h>

#define FMIX_ERR_INVALID_CHUNK (0x40000001)

int32_t FMix_OpenAudio(int32_t freq, int32_t chunksize, uint16_t format, int32_t channels);
Mix_Chunk* FMix_Read(char* file);
int32_t FMix_Play(Mix_Chunk* chunk);
int32_t FMix_Init(int32_t flags);
int32_t FMix_Quit();

#endif
