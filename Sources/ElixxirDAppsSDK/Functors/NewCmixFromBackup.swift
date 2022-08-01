import Bindings
import XCTestDynamicOverlay

public struct NewCmixFromBackup {
  public var run: (String, String, String, Data, Data) throws -> BackupReport

  public func callAsFunction(
    ndfJSON: String,
    storageDir: String,
    backupPassphrase: String,
    sessionPassword: Data,
    backupFileContents: Data
  ) throws -> BackupReport {
    try run(ndfJSON, storageDir, backupPassphrase, sessionPassword, backupFileContents)
  }
}

extension NewCmixFromBackup {
  public static let live = NewCmixFromBackup {
    ndfJSON, storageDir, backupPassphrase, sessionPassword, backupFileContents in

    var error: NSError?
    let reportData = BindingsNewCmixFromBackup(
      ndfJSON,
      storageDir,
      backupPassphrase,
      sessionPassword,
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
