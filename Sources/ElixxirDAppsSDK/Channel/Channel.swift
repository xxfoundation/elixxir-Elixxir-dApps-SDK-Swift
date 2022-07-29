import Bindings

public struct Channel {
  public var broadcast: ChannelBroadcast
  public var broadcastAsymmetric: ChannelBroadcastAsymmetric
  public var get: ChannelGet
  public var listen: ChannelListen
  public var maxAsymmetricPayloadSize: ChannelMaxAsymmetricPayloadSize
  public var maxPayloadSize: ChannelMaxPayloadSize
  public var stop: ChannelStop
}

extension Channel {
  public static func live(_ bindingsChannel: BindingsChannel) -> Channel {
    Channel(
      broadcast: .live(bindingsChannel),
      broadcastAsymmetric: .live(bindingsChannel),
      get: .live(bindingsChannel),
      listen: .live(bindingsChannel),
      maxAsymmetricPayloadSize: .live(bindingsChannel),
      maxPayloadSize: .live(bindingsChannel),
      stop: .live(bindingsChannel)
    )
  }
}

extension Channel {
  public static let unimplemented = Channel(
    broadcast: .unimplemented,
    broadcastAsymmetric: .unimplemented,
    get: .unimplemented,
    listen: .unimplemented,
    maxAsymmetricPayloadSize: .unimplemented,
    maxPayloadSize: .unimplemented,
    stop: .unimplemented
  )
}
