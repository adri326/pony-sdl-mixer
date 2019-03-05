use "time"

actor FMixEventHandler
  let listeners: Array[FMixListener ref] ref = Array[FMixListener ref]
  let timers: Timers = Timers

  new create() =>
    @FMix_RegisterEventHandler[None](this)
    @printf[None]("Seeded -> %p\n".cpointer(), this)
    timers(Timer(_FMixListenerNotify(this), 100_000_000, 100_000_000))

  be apply(listener: FMixListener iso) =>
    listeners.push(consume listener)

  be stop() =>
    @FMix_DestroyHandler[None](this)

  be test() =>
    @printf[None]("Success!\n".cpointer())

  fun @event_handler(handler: FMixEventHandler tag, channel: I32, kind: I32) =>
    // attempt to fix the segfault:
    @pony_register_thread[None]()
    @printf[None]("Received -> %p %d %d\n".cpointer(), handler, channel, kind)
    handler.test()

// keep the parent FMixListener alive
class _FMixListenerNotify is TimerNotify
  let _listener: FMixEventHandler tag
  new iso create(listener: FMixEventHandler tag) =>
    _listener = listener

  fun ref apply(timer: Timer, count: U64): Bool =>
    // @printf[None]("Never gonna let you down!\n".cpointer())
    true

class FMixEventHelper
  let channel: I32
  let kind: I32
  let handler: FMixEventHandler tag

  new val create(channel': I32, kind': I32, handler': FMixEventHandler tag) =>
    channel = channel'
    kind = kind'
    handler = handler'

interface FMixListener
  fun ref apply(event: FMixEventHelper val)

primitive FMixEventChannelFinished
