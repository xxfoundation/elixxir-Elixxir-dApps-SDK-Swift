import Bindings
import XCTestDynamicOverlay

public struct ChannelBroadcastAsymmetric {
  public var run: (Data, Data) throws -> Data

  public func callAsFunction(
    payload: Data,
    privateKey: Data
  ) throws -> Data {
    try run(payload, privateKey)
  }
}

extension ChannelBroadcastAsymmetric {
  public static func live(_ bindingsChannel: BindingsChannel) -> ChannelBroadcastAsymmetric {
    ChannelBroadcastAsymmetric(run: bindingsChannel.broadcastAsymmetric(_:pk:))
  }
}

extension ChannelBroadcastAsymmetric {
  public static let unimplemented = ChannelBroadcastAsymmetric(
    run: XCTUnimplemented("\(Self.self)")
  )
}
