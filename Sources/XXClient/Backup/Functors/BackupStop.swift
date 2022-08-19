import Bindings
import XCTestDynamicOverlay

public struct BackupStop {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension BackupStop {
  public static func live(_ bindingsBackup: BindingsBackup) -> BackupStop {
    BackupStop(run: bindingsBackup.stop)
  }
}

extension BackupStop {
  public static let unimplemented = BackupStop(
    run: XCTUnimplemented("\(Self.self)")
  )
}
