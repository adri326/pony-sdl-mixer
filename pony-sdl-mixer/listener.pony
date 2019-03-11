use "time"

actor FMixEventHandler
  let listeners: Array[FMixListener ref] ref = Array[FMixListener ref]
  let timers: Timers = Timers

  new create() =>
    @FMix_RegisterEventHandler[None](this)
    @printf[None]("Seeded -> %p\n".cpointer(), this)
    timers(Timer(_FMixListenerNotify(this), 1_000_000_000, 1_000_000_000))

  be apply(listener: FMixListener iso) =>
    listeners.push(consume listener)

  be stop() =>
    @FMix_DestroyHandler[None](this)
    timers.dispose()

  be _dispatch(channel: I32, kind: I32) =>
    let kind' = match kind
    | 1 => FMixEventChannelFinished
    else None
    end
    let helper = FMixEventHelper(channel, kind', this)
    for listener in listeners.values() do
      listener(helper)
    end

  fun @event_handler(handler: FMixEventHandler tag, channel: I32, kind: I32) =>
    handler._dispatch(channel, kind)

// keep the parent FMixListener alive
class _FMixListenerNotify is TimerNotify
  let _listener: FMixEventHandler tag
  
  new iso create(listener: FMixEventHandler tag) =>
    _listener = listener

  fun ref apply(timer: Timer, count: U64): Bool => true

class FMixEventHelper
  let channel: I32
  let kind: FMixEvent
  let handler: FMixEventHandler tag

  new val create(channel': I32, kind': FMixEvent, handler': FMixEventHandler tag) =>
    channel = channel'
    kind = kind'
    handler = handler'

interface FMixListener
  fun ref apply(event: FMixEventHelper val)

primitive FMixEventChannelFinished
type FMixEvent is (FMixEventChannelFinished | None)
