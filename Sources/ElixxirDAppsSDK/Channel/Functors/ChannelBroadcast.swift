import Bindings
import XCTestDynamicOverlay

public struct ChannelBroadcast {
  public var run: (Data) throws -> Data

  public func callAsFunction(_ payload: Data) throws -> Data {
    try run(payload)
  }
}

extension ChannelBroadcast {
  public static func live(_ bindingsChannel: BindingsChannel) -> ChannelBroadcast {
    ChannelBroadcast(run: bindingsChannel.broadcast)
  }
}

extension ChannelBroadcast {
  public static let unimplemented = ChannelBroadcast(
    run: XCTUnimplemented("\(Self.self)")
  )
}
