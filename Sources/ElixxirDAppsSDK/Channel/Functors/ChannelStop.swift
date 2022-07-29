import Bindings
import XCTestDynamicOverlay

public struct ChannelStop {
  public var run: () -> Void

  public func callAsFunction() {
    run()
  }
}

extension ChannelStop {
  public static func live(_ bindingsChannel: BindingsChannel) -> ChannelStop {
    ChannelStop(run: bindingsChannel.stop)
  }
}

extension ChannelStop {
  public static let unimplemented = ChannelStop(
    run: XCTUnimplemented("\(Self.self)")
  )
}
