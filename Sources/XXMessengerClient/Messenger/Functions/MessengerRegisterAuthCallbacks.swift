import XXClient
import XCTestDynamicOverlay

public struct MessengerRegisterAuthCallbacks {
  public var run: (AuthCallbacks) -> Cancellable

  public func callAsFunction(_ authCallbacks: AuthCallbacks) -> Cancellable {
    run(authCallbacks)
  }
}

extension MessengerRegisterAuthCallbacks {
  public static func live(_ env: MessengerEnvironment) -> MessengerRegisterAuthCallbacks {
    MessengerRegisterAuthCallbacks { callback in
      env.authCallbacks.register(callback)
    }
  }
}

extension MessengerRegisterAuthCallbacks {
  public static let unimplemented = MessengerRegisterAuthCallbacks(
    run: XCTUnimplemented("\(Self.self)")
  )
}
