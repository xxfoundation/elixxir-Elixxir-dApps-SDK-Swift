import XCTestDynamicOverlay
import XXClient

public struct MessengerIsBackupRunning {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension MessengerIsBackupRunning {
  public static func live(_ env: MessengerEnvironment) -> MessengerIsBackupRunning {
    MessengerIsBackupRunning {
      env.backup()?.isRunning() == true
    }
  }
}

extension MessengerIsBackupRunning {
  public static let unimplemented = MessengerIsBackupRunning(
    run: XCTUnimplemented("\(Self.self)", placeholder: false)
  )
}
