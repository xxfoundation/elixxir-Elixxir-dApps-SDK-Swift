import XCTestDynamicOverlay
import XXClient

public struct MessengerRegisterBackupCallback {
  public var run: (UpdateBackupFunc) -> Cancellable

  public func callAsFunction(_ callback: UpdateBackupFunc) -> Cancellable {
    run(callback)
  }
}

extension MessengerRegisterBackupCallback {
  public static func live(_ env: MessengerEnvironment) -> MessengerRegisterBackupCallback {
    MessengerRegisterBackupCallback { callback in
      env.backupCallbacks.register(callback)
    }
  }
}

extension MessengerRegisterBackupCallback {
  public static let unimplemented = MessengerRegisterBackupCallback(
    run: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
