use "time"

actor FMixEventHandler
  let listeners: Array[FMixListener ref] ref = Array[FMixListener ref]
  let timers: Timers = Timers

  new create() =>
    """
    Creates a new event handler. It will self-maintain itself, which means that you have to `stop` it by yourself. If you do not want this behavior, you may use the `no_timer` constructor.

    The self-maintaining procedure uses, as of right now, a `Timer`.
    """
    @FMix_RegisterEventHandler[None](this)
    timers(Timer(_FMixListenerNotify(this), 10_000_000_000, 10_000_000_000))

  new no_timer() =>
    """
    Creates a new event handler, without self-maintaining mechanism.
    """
    @FMix_RegisterEventHandler[None](this)

  be apply(listener: FMixListener iso) =>
    """
    Add a listener to the event handler; it will be called on every event
    """
    listeners.push(consume listener)

  be dispose() =>
    """
    Stop the event handler, including its self-maintaining mechanism and destroys its C reference.
    """
    @FMix_DestroyHandler[None](this)
    timers.dispose()

  be _dispatch(channel: I32, kind: I32) =>
    """
    Called when dispatching events
    """
    let kind' = match kind
    | 1 => FMixEventChannelFinished
    else None
    end
    let helper = FMixEventHelper(channel, kind', this)
    for listener in listeners.values() do
      listener(helper)
    end

  fun @event_handler(handler: FMixEventHandler tag, channel: I32, kind: I32) =>
    """
    The bit of code that C will call
    """
    handler._dispatch(channel, kind)

class _FMixListenerNotify is TimerNotify
  """
  FMixEventHandlers' self-maintaining slave.
  """
  let _listener: FMixEventHandler tag

  new iso create(listener: FMixEventHandler tag) =>
    _listener = listener

  fun ref apply(timer: Timer, count: U64): Bool => true

class FMixEventHelper
  """
  A helper class for events
  """
  let channel: I32
  let kind: FMixEvent
  let handler: FMixEventHandler tag

  new val create(channel': I32, kind': FMixEvent, handler': FMixEventHandler tag) =>
    channel = channel'
    kind = kind'
    handler = handler'

interface FMixListener
  """
  Interface for what your listener should be like.
  """
  fun ref apply(event: FMixEventHelper val)

primitive FMixEventChannelFinished
type FMixEvent is (FMixEventChannelFinished | None)
