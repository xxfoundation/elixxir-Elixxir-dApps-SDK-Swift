import Bindings
import XCTestDynamicOverlay

public struct ChannelBroadcast {
  public var run: (Data) throws -> BroadcastReport

  public func callAsFunction(_ payload: Data) throws -> BroadcastReport {
    try run(payload)
  }
}

extension ChannelBroadcast {
  public static func live(_ bindingsChannel: BindingsChannel) -> ChannelBroadcast {
    ChannelBroadcast { payload in
      let reportData = try bindingsChannel.broadcast(payload)
      return try BroadcastReport.decode(reportData)
    }
  }
}

extension ChannelBroadcast {
  public static let unimplemented = ChannelBroadcast(
    run: XCTUnimplemented("\(Self.self)")
  )
}
