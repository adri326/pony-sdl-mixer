use "time"

actor FMixEventHandler
  let listeners: Array[FMixListener ref] ref
  let timers: Timers
  var valid: Bool = true

  new create(delta: U64 = 100_000_000) =>
    listeners = Array[FMixListener ref]
    @FMix_RegisterEventHandler[None](this)
    timers = Timers()
    timers(Timer(_FMixEventNotifier(this), delta, delta))

  be apply(listener: FMixListener iso) =>
    if valid then
      listeners.push(consume listener)
    end

  be dispatch(event: FMixEventHelper val) =>
    for listener in listeners.values() do
      listener(event)
    end

  be stop() =>
    valid = false
    timers.dispose()

  fun _final() =>
    @FMix_DestroyHandler[None](this)

class _FMixEventNotifier is TimerNotify
  let handler: FMixEventHandler tag

  new iso create(handler': FMixEventHandler tag) =>
    handler = handler'

  fun apply(timer: Timer, count: U64): Bool =>
    var res = I8(1)
    while res == 1 do
      var channel: I32 = 0
      var kind: I32 = 0
      res = @FMix_CheckoutEvent[I8](handler, addressof channel, addressof kind)
      if res == 1 then
        handler.dispatch(FMixEventHelper(channel, kind, handler))
      end
    end
    true

interface FMixListener
  fun ref apply(event: FMixEventHelper val)

class FMixEventHelper
  let channel: I32
  let kind: I32
  let handler: FMixEventHandler tag

  new val create(channel': I32, kind': I32, handler': FMixEventHandler tag) =>
    channel = channel'
    kind = kind'
    handler = handler'

primitive FMixEventChannelFinished
