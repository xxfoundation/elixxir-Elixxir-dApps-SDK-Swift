import XXClient
import XCTestDynamicOverlay

public struct MessengerE2E {
  public var run: () -> E2E?

  public func callAsFunction() -> E2E? {
    run()
  }
}

extension MessengerE2E {
  public static func live(_ env: MessengerEnvironment) -> MessengerE2E {
    MessengerE2E(run: env.ctx.getE2E)
  }
}

extension MessengerE2E {
  public static let unimplemented = MessengerE2E(
    run: XCTUnimplemented("\(Self.self)", placeholder: nil)
  )
}
