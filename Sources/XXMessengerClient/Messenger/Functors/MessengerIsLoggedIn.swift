import XXClient
import XCTestDynamicOverlay

public struct MessengerIsLoggedIn {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension MessengerIsLoggedIn {
  public static func live(_ env: MessengerEnvironment) -> MessengerIsLoggedIn {
    MessengerIsLoggedIn {
      env.ud() != nil
    }
  }
}

extension MessengerIsLoggedIn {
  public static let unimplemented = MessengerIsLoggedIn(
    run: XCTUnimplemented()
  )
}
