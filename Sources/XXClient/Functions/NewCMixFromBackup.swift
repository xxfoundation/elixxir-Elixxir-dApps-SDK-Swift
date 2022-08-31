import Bindings
import XCTestDynamicOverlay

public struct NewCMixFromBackup {
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

extension NewCMixFromBackup {
  public static let live = NewCMixFromBackup {
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
      fatalError("BindingsNewCMixFromBackup returned `nil` without providing error")
    }
    return try BackupReport.decode(reportData)
  }
}

extension NewCMixFromBackup {
  public static let unimplemented = NewCMixFromBackup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
