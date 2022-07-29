import Bindings
import XCTestDynamicOverlay

public struct ChannelListen {
  public var run: (Int, BroadcastListener) throws -> Void

  public func callAsFunction(
    method: Int,
    callback: BroadcastListener
  ) throws {
    try run(method, callback)
  }
}

extension ChannelListen {
  public static func live(_ bindingsChannel: BindingsChannel) -> ChannelListen {
    ChannelListen { method, callback in
      try bindingsChannel.listen(
        callback.makeBindingsBroadcastListener(),
        method: method
      )
    }
  }
}

extension ChannelListen {
  public static let unimplemented = ChannelListen(
    run: XCTUnimplemented("\(Self.self)")
  )
}
