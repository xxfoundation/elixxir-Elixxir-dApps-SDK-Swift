import XXClient
import XCTestDynamicOverlay

public struct MessengerUD {
  public var run: () -> UserDiscovery?

  public func callAsFunction() -> UserDiscovery? {
    run()
  }
}

extension MessengerUD {
  public static func live(_ env: MessengerEnvironment) -> MessengerUD {
    MessengerUD(run: env.ctx.getUD)
  }
}

extension MessengerUD {
  public static let unimplemented = MessengerUD(
    run: XCTUnimplemented("\(Self.self)", placeholder: nil)
  )
}
