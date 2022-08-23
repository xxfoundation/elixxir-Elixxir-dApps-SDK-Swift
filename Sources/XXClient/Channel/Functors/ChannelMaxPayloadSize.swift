import Bindings
import XCTestDynamicOverlay

public struct ChannelMaxPayloadSize {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension ChannelMaxPayloadSize {
  public static func live(_ bindingsChannel: BindingsChannel) -> ChannelMaxPayloadSize {
    ChannelMaxPayloadSize(run: bindingsChannel.maxPayloadSize)
  }
}

extension ChannelMaxPayloadSize {
  public static let unimplemented = ChannelMaxPayloadSize(
    run: XCTUnimplemented("\(Self.self)", placeholder: 0)
  )
}
