import Bindings
import XCTestDynamicOverlay

public struct BackupIsRunning {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension BackupIsRunning {
  public static func live(_ bindingsBackup: BindingsBackup) -> BackupIsRunning {
    BackupIsRunning(run: bindingsBackup.isBackupRunning)
  }
}

extension BackupIsRunning {
  public static let unimplemented = BackupIsRunning(
    run: XCTUnimplemented("\(Self.self)")
  )
}
