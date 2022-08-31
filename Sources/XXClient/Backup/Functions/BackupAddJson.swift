import Bindings
import XCTestDynamicOverlay

public struct BackupAddJSON {
  public var run: (String) -> Void

  public func callAsFunction(_ jsonString: String) {
    run(jsonString)
  }
}

extension BackupAddJSON {
  public static func live(_ bindingsBackup: BindingsBackup) -> BackupAddJSON {
    BackupAddJSON(run: bindingsBackup.addJson)
  }
}

extension BackupAddJSON {
  public static let unimplemented = BackupAddJSON(
    run: XCTUnimplemented("\(Self.self)")
  )
}
