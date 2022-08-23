import Bindings
import XCTestDynamicOverlay

public struct ChannelMaxAsymmetricPayloadSize {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension ChannelMaxAsymmetricPayloadSize {
  public static func live(_ bindingsChannel: BindingsChannel) -> ChannelMaxAsymmetricPayloadSize {
    ChannelMaxAsymmetricPayloadSize(run: bindingsChannel.maxAsymmetricPayloadSize)
  }
}

extension ChannelMaxAsymmetricPayloadSize {
  public static let unimplemented = ChannelMaxAsymmetricPayloadSize(
    run: XCTUnimplemented("\(Self.self)", placeholder: 0)
  )
}
