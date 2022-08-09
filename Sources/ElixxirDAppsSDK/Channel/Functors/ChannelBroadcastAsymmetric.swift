import Bindings
import XCTestDynamicOverlay

public struct ChannelBroadcastAsymmetric {
  public var run: (Data, Data) throws -> BroadcastReport

  public func callAsFunction(
    payload: Data,
    privateKey: Data
  ) throws -> BroadcastReport {
    try run(payload, privateKey)
  }
}

extension ChannelBroadcastAsymmetric {
  public static func live(_ bindingsChannel: BindingsChannel) -> ChannelBroadcastAsymmetric {
    ChannelBroadcastAsymmetric { payload, privateKey in
      let reportData = try bindingsChannel.broadcastAsymmetric(payload, pk: privateKey)
      return try BroadcastReport.decode(reportData)
    }
  }
}

extension ChannelBroadcastAsymmetric {
  public static let unimplemented = ChannelBroadcastAsymmetric(
    run: XCTUnimplemented("\(Self.self)")
  )
}
