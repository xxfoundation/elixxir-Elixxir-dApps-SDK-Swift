import Bindings
import XCTestDynamicOverlay

public struct NewCmixFromBackup {
  public var run: (String, String, Data, Data, Data) throws -> BackupReport

  public func callAsFunction(
    ndfJSON: String,
    storageDir: String,
    sessionPassword: Data,
    backupPassphrase: Data,
    backupFileContents: Data
  ) throws -> BackupReport {
    try run(ndfJSON, storageDir, sessionPassword, backupPassphrase, backupFileContents)
  }
}

extension NewCmixFromBackup {
  public static let live = NewCmixFromBackup {
    ndfJSON, storageDir, sessionPassword, backupPassphrase, backupFileContents in

    var error: NSError?
    let reportData = BindingsNewCmixFromBackup(
      ndfJSON,
      storageDir,
      sessionPassword,
      backupPassphrase,
      backupFileContents,
      &error
    )
    if let error = error {
      throw error
    }
    guard let reportData = reportData else {
      fatalError("BindingsNewCmixFromBackup returned `nil` without providing error")
    }
    return try BackupReport.decode(reportData)
  }
}

extension NewCmixFromBackup {
  public static let unimplemented = NewCmixFromBackup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
