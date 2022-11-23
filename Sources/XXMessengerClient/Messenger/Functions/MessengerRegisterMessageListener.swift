import XCTestDynamicOverlay
import XXClient

public struct MessengerRegisterMessageListener {
  public var run: (Listener) -> Cancellable

  public func callAsFunction(_ listener: Listener) -> Cancellable {
    run(listener)
  }
}

extension MessengerRegisterMessageListener {
  public static func live(_ env: MessengerEnvironment) -> MessengerRegisterMessageListener {
    MessengerRegisterMessageListener { listener in
      env.messageListeners.register(listener)
    }
  }
}

extension MessengerRegisterMessageListener {
  public static let unimplemented = MessengerRegisterMessageListener(
    run: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
