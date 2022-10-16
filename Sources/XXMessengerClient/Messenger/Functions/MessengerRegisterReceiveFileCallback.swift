import XCTestDynamicOverlay
import XXClient

public struct MessengerRegisterReceiveFileCallback {
  public var run: (ReceiveFileCallback) -> Cancellable

  public func callAsFunction(_ callback: ReceiveFileCallback) -> Cancellable {
    run(callback)
  }
}

extension MessengerRegisterReceiveFileCallback {
  public static func live(_ env: MessengerEnvironment) -> MessengerRegisterReceiveFileCallback {
    MessengerRegisterReceiveFileCallback { callback in
      env.receiveFileCallbacks.register(callback)
    }
  }
}

extension MessengerRegisterReceiveFileCallback {
  public static let unimplemented = MessengerRegisterReceiveFileCallback(
    run: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
