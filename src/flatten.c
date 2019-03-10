#include "flatten.h"

static FMix_Status** _chunks = NULL;
static size_t _chunks_length = 0;

static FMix_EventHandler** _evt_handlers = NULL;
static size_t _evt_handlers_length = 0;
static FMix_Event* last_event = NULL;

// init FMix
int32_t FMix_Init(int32_t flags) {
  Mix_ChannelFinished(&_FMix_ChannelHandler);
  _evt_handlers = (FMix_EventHandler**)malloc(sizeof(FMix_EventHandler*) * 256);
  _evt_handlers_length = 256;
  for (size_t n = 0; n < _evt_handlers_length; n++) {
    _evt_handlers[n] = NULL;
  }

  last_event = (FMix_Event*)malloc(sizeof(FMix_Event));
  last_event->channel = 0;
  last_event->kind = FMIX_EVENT_NULL;
  last_event->index = 0;
  last_event->next = NULL;

  return Mix_Init(flags);
}

// sets the ChannelFinished handler
void _FMix_SetChannelFinished(void (*fn)(int channel)) {
  Mix_ChannelFinished(fn);
}

// returns the compiled version of SDL_mixer
void FMix_CompiledVersion(int32_t* major, int32_t* minor, int32_t* patch) {
  SDL_version compile_version;
  SDL_MIXER_VERSION(&compile_version);
  *major = compile_version.major;
  *minor = compile_version.minor;
  *patch = compile_version.patch;
}

// returns the linked version of SDL_mixer
void FMix_LinkedVersion(int32_t* major, int32_t* minor, int32_t* patch) {
  const SDL_version* link_version = Mix_Linked_Version();
  *major = link_version->major;
  *minor = link_version->minor;
  *patch = link_version->patch;
}

// opens the audio interface
int32_t FMix_OpenAudio(int32_t freq, int32_t chunksize, uint16_t format, int32_t channels) {
  int32_t res;
  int32_t n;
  if (format == 0) {
    res = Mix_OpenAudio(freq, MIX_DEFAULT_FORMAT, channels, chunksize);
  } else {
    res = Mix_OpenAudio(freq, format, channels, chunksize);
  }
  _FMix_UpdateStaticChunksLength();
  return res;
}

// update the `_chunk` object
void _FMix_UpdateStaticChunksLength() {
  int32_t n_chunks_length = FMix_AllocatedChannels();
  int32_t n;
  FMix_Status** n_chunks = (FMix_Status**)malloc(sizeof(FMix_Status*) * n_chunks_length);
  if (_chunks_length < n_chunks_length) {
    for (n = 0; n < _chunks_length; n++) {
      n_chunks[n] = _chunks[n];
    }
    for (n = _chunks_length; n < n_chunks_length; n++) {
      n_chunks[n] = (FMix_Status*)malloc(sizeof(FMix_Status));
      n_chunks[n]->chunk = NULL;
      n_chunks[n]->playing = 0;
      n_chunks[n]->garbage = 0;
    }
  } else if (_chunks_length > n_chunks_length) {
    for (n = 0; n < n_chunks_length; n++) {
      n_chunks[n] = _chunks[n];
    }
    for (n = n_chunks_length; n < _chunks_length; n++) {
      free(_chunks[n]);
    }
  }
  _chunks_length = n_chunks_length;
  free(_chunks);
  _chunks = n_chunks;
}

// close the audio interface and collect the garbage chunks
void FMix_CloseAudio() {
  for (int32_t n = 0; n < _chunks_length; n++) {
    if (_chunks[n]->garbage && _chunks[n]->chunk != NULL) {
      Mix_FreeChunk(_chunks[n]->chunk);
      for (int32_t o = n; o < _chunks_length; o++) {
        if (_chunks[o]->chunk == _chunks[n]->chunk) _chunks[o]->chunk = NULL;
      }
    }
    free(_chunks[n]);
  }
  free(_chunks);
  _chunks_length = 0;
  Mix_CloseAudio();
}

// queries the specs of the audio interface/tunnel
int32_t FMix_QuerySpec(int32_t* frequency, uint16_t* format, int32_t* channels, int32_t* consecutive_opens) {
  int32_t res = Mix_QuerySpec(frequency, format, channels);
  if (res == 0) return -1;
  *consecutive_opens = res;
  return 0;
}

// reads a file as a chunk
Mix_Chunk* FMix_Read(char* file) {
  SDL_RWops* rw_ops = SDL_RWFromFile(file, "rb");
  if (rw_ops == NULL) {
    return NULL;
  }
  return Mix_LoadWAV_RW(rw_ops, 1);
}

// plays a chunk in the first available channel or in the nth channel
int32_t FMix_Play(Mix_Chunk* chunk, int32_t channel) {
  if (chunk == NULL) return FMIX_ERR_INVALID_CHUNK;
  int32_t res = Mix_PlayChannel(channel, chunk, 0);
  if (res >= 0 && res < _chunks_length) {
    _chunks[res]->chunk = chunk;
    _chunks[res]->garbage = false;
    _chunks[res]->playing = true;
  }
  return res;
}

// attempts to free a chunk if it isn't already
void FMix_FreeChunk(Mix_Chunk* chunk) {
  bool collect = true;
  for (int32_t n = 0; n < _chunks_length; n++) {
    if (_chunks[n]->chunk == chunk) {
      _chunks[n]->garbage = true;
      collect = collect && !(_chunks[n]->playing);
    }
  }
  if (collect) {
    Mix_FreeChunk(chunk);
    for (int32_t n = 0; n < _chunks_length; n++) {
      if (_chunks[n]->chunk == chunk) _chunks[n]->chunk = NULL;
    }
  }
}

// quit FMix
int32_t FMix_Quit() {
  Mix_Quit();
  return Mix_Init(0);
}

// allocated n mixer channel
int32_t FMix_AllocateChannels(int32_t n) {
  int32_t res =  Mix_AllocateChannels(n);
  _FMix_UpdateStaticChunksLength();
  return res != n;
}

// returns the amount of allocated channels
int32_t FMix_AllocatedChannels() {
  return Mix_AllocateChannels(-1);
}

int32_t FMix_Playing(int32_t channel) {
  return Mix_Playing(channel);
}

// sets the volume for a channel
int32_t FMix_SetVolume(int32_t channel, int32_t volume) {
  return Mix_Volume(channel, volume);
}

// gets the volume of a channel
int32_t FMix_GetVolume(int32_t channel) {
  return Mix_Volume(channel, -1);
}

// sets the volume of a chunk
void FMix_SetChunkVolume(Mix_Chunk* chunk, int32_t volume) {
  Mix_VolumeChunk(chunk, volume);
}

// gets the volume of a chunk
int32_t FMix_GetChunkVolume(Mix_Chunk* chunk) {
  return Mix_VolumeChunk(chunk, -1);
}

// gets the chunk played in the nth channel; should not be used when GCing (it causes a segfault for some reason)
Mix_Chunk* FMix_GetChunk(int32_t channel) {
  return Mix_GetChunk(channel);
}

// safe, chunk retrieval, using the static `_chunk` object
Mix_Chunk* FMix_GetChunkStatic(int32_t channel) {
  if (channel < _chunks_length && channel >= 0) {
    return _chunks[channel]->chunk;
  } else return NULL;
}

int8_t FMix_IsChannelPlaying(int32_t channel) {
  if (channel < _chunks_length && channel >= 0) {
    return _chunks[channel]->playing;
  } else return false;
}

// the channel handler for this program
static void _FMix_ChannelHandler(int channel) {
  if (channel < _chunks_length && channel >= 0) {
    _chunks[channel]->playing = false;
    if (_chunks[channel]->chunk != NULL && _chunks[channel]->garbage) {
      FMix_FreeChunk(_chunks[channel]->chunk);
    }
  }
  FMix_CreateEvent(channel, FMIX_EVENT_CHANNEL_FINISHED);
}

// create a new event and append it to the linked list
void FMix_CreateEvent(int32_t channel, int32_t kind) {
  FMix_Event* n_last_event = (FMix_Event*)malloc(sizeof(FMix_Event));
  n_last_event->channel = channel;
  n_last_event->kind = kind;
  n_last_event->index = last_event->index + 1;
  n_last_event->next = NULL;
  last_event->next = n_last_event;
  last_event = n_last_event;
}

void FMix_RegisterEventHandler(size_t uid) {
  // printf("> %p\n", listener);
  for (size_t n = 0; n < _evt_handlers_length; n++) {
    if (_evt_handlers[n] == NULL) {
      _evt_handlers[n] = (FMix_EventHandler*)malloc(sizeof(FMix_EventHandler));
      _evt_handlers[n]->uid = uid;
      _evt_handlers[n]->last_event = last_event;
      return;
    }
  }

  // allocate more memory
  size_t n_evt_handlers_length = _evt_handlers_length + 256;
  FMix_EventHandler** n_evt_handlers = (FMix_EventHandler**)malloc(sizeof(FMix_EventHandler*) * n_evt_handlers_length);
  for (size_t n = 0; n < _evt_handlers_length; n++) {
    n_evt_handlers[n] = _evt_handlers[n];
  }
  for (size_t n = _evt_handlers_length + 1; n < n_evt_handlers_length; n++) {
    n_evt_handlers[n] = NULL;
  }

  // create a write new event handler
  n_evt_handlers[_evt_handlers_length] = (FMix_EventHandler*)malloc(sizeof(FMix_EventHandler));
  n_evt_handlers[_evt_handlers_length]->uid = uid;
  n_evt_handlers[_evt_handlers_length]->last_event = last_event;

  // overwrite the old event handler
  FMix_EventHandler** old_evt_handlers = _evt_handlers;
  _evt_handlers = n_evt_handlers;
  _evt_handlers_length = n_evt_handlers_length;
  free(old_evt_handlers);
}

// NOTE: this might be error-prone
void FMix_DestroyHandler(size_t uid) {
  for (size_t n = 0; n < _evt_handlers_length; n++) {
    if (_evt_handlers[n] != NULL && _evt_handlers[n]->uid == uid) {
      FMix_Event* event = _evt_handlers[n]->last_event;
      free(_evt_handlers[n]);
      _evt_handlers[n] = NULL;
      while (event != NULL) {
        FMix_Event* old_event = event;
        event = event->next;
        FMix_FreeEvent(old_event);
      }
    }
  }
}

// 0 means no new event, the data you just got is the previous event, 1 means that the event fetched is the last one, 2 means that there are more events coming up
int8_t FMix_CheckoutEvent(size_t uid, int32_t* channel, int32_t* kind) {
  for (size_t n = 0; n < _evt_handlers_length; n++) {
    if (_evt_handlers[n] != NULL && _evt_handlers[n]->uid == uid) {
      FMix_EventHandler* handler = _evt_handlers[n];
      FMix_Event* event = handler->last_event;
      if (event->next != NULL) {
        *channel = event->next->channel;
        *kind = event->next->kind;
        handler->last_event = event->next;
        FMix_FreeEvent(event);
        return 1;
      }
      else return 0;
    }
  }
}

// attempt to free an event; nothing will be done if it could still be read by a handler
void FMix_FreeEvent(FMix_Event* evt) {
  if (evt == NULL) return;
  for (size_t n = 0; n < _evt_handlers_length; n++) {
    // if an event handler is behind the current event: do not free
    if (_evt_handlers[n] != NULL && _evt_handlers[n]->last_event->index <= evt->index) return;
  }
  free(evt);
}

int32_t FMix_GetChunkLength(Mix_Chunk* chunk) {
  int freq;
  uint16_t format;
  int channels;
  if (Mix_QuerySpec(&freq, &format, &channels) == 0) return -1;


  uint64_t bytesize = 4;
  switch (format) {
    case AUDIO_U8:
    case AUDIO_S8:
      bytesize = 1;
      break;
    case AUDIO_U16LSB:
    case AUDIO_S16LSB:
    case AUDIO_U16MSB:
    case AUDIO_S16MSB:
      bytesize = 2;
      break;
  }

  uint32_t alen = chunk->alen;
  return (uint32_t)((uint64_t)alen * 1000 / freq / 4);
}
