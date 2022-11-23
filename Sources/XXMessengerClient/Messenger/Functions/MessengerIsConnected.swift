import XXClient
import XCTestDynamicOverlay

public struct MessengerIsConnected {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension MessengerIsConnected {
  public static func live(_ env: MessengerEnvironment) -> MessengerIsConnected {
    MessengerIsConnected {
      env.e2e() != nil
    }
  }
}

extension MessengerIsConnected {
  public static let unimplemented = MessengerIsConnected(
    run: XCTUnimplemented("\(Self.self)", placeholder: false)
  )
}

