import Bindings
import XCTestDynamicOverlay

public struct InitializeBackup {
  public var run: (Int, Int, String, UpdateBackupFunc) throws -> Backup

  public func callAsFunction(
    e2eId: Int,
    udId: Int,
    password: String,
    callback: UpdateBackupFunc
  ) throws -> Backup {
    try run(e2eId, udId, password, callback)
  }
}

extension InitializeBackup {
  public static let live = InitializeBackup { e2eId, udId, password, callback in
    var error: NSError?
    let bindingsBackup = BindingsInitializeBackup(
      e2eId,
      udId,
      password,
      callback.makeBindingsUpdateBackupFunc(),
      &error
    )
    if let error = error {
      throw error
    }
    guard let bindingsBackup = bindingsBackup else {
      fatalError("BindingsInitializeBackup returned `nil` without providing error")
    }
    return .live(bindingsBackup)
  }
}

extension InitializeBackup {
  public static let unimplemented = InitializeBackup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
