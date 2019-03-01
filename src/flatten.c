#include "flatten.h"

int32_t FMix_OpenAudio(int32_t freq, int32_t chunksize, uint16_t format, int32_t channels) {
  if (format == 0) {
    return Mix_OpenAudio(freq, MIX_DEFAULT_FORMAT, channels, chunksize);
  } else {
    return Mix_OpenAudio(freq, format, channels, chunksize);
  }
}

Mix_Chunk* FMix_Read(char* file) {
  SDL_RWops* rw_ops = SDL_RWFromFile(file, "rb");
  if (rw_ops == NULL) {
    return NULL;
  }
  return Mix_LoadWAV_RW(rw_ops, 1);
}

int32_t FMix_Play(Mix_Chunk* chunk) {
  if (chunk == NULL) return FMIX_ERR_INVALID_CHUNK;
  int32_t res = Mix_PlayChannel(-1, chunk, 0);
  return res;
}

int32_t FMix_Init(int32_t flags) {
  return Mix_Init(flags);
}

int32_t FMix_Quit() {
  Mix_Quit();
  return Mix_Init(0);
}
