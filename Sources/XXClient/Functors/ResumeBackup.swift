import Bindings
import XCTestDynamicOverlay

public struct ResumeBackup {
  public var run: (Int, Int, UpdateBackupFunc) throws -> Backup

  public func callAsFunction(
    e2eId: Int,
    udId: Int,
    callback: UpdateBackupFunc
  ) throws -> Backup {
    try run(e2eId, udId, callback)
  }
}

extension ResumeBackup {
  public static let live = ResumeBackup { e2eId, udId, callback in
    var error: NSError?
    let bindingsBackup = BindingsResumeBackup(
      e2eId,
      udId,
      callback.makeBindingsUpdateBackupFunc(),
      &error
    )
    if let error = error {
      throw error
    }
    guard let bindingsBackup = bindingsBackup else {
      fatalError("BindingsResumeBackup returned `nil` without providing error")
    }
    return .live(bindingsBackup)
  }
}

extension ResumeBackup {
  public static let unimplemented = ResumeBackup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
