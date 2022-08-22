import XXClient
import XCTestDynamicOverlay

public struct MessengerCMix {
  public var run: () -> CMix?

  public func callAsFunction() -> CMix? {
    run()
  }
}

extension MessengerCMix {
  public static func live(_ env: MessengerEnvironment) -> MessengerCMix {
    MessengerCMix(run: env.ctx.getCMix)
  }
}

extension MessengerCMix {
  public static let unimplemented = MessengerCMix(
    run: XCTUnimplemented("\(Self.self)", placeholder: nil)
  )
}
