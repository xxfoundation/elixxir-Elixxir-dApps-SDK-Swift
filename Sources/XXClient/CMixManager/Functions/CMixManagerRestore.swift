import Foundation
import XCTestDynamicOverlay

public struct CMixManagerRestore {
  public var run: (Data, String) throws -> BackupReport

  public func callAsFunction(
    backup: Data,
    passphrase: String
  ) throws -> BackupReport {
    try run(backup, passphrase)
  }
}

extension CMixManagerRestore {
  public static func live(
    ndfEnvironment: NDFEnvironment,
    downloadNDF: DownloadAndVerifySignedNdf,
    generateSecret: GenerateSecret,
    passwordStorage: PasswordStorage,
    directoryPath: String,
    fileManager: FileManager,
    newCMixFromBackup: NewCMixFromBackup
  ) -> CMixManagerRestore {
    CMixManagerRestore { backup, passphrase in
      let ndfData = try downloadNDF(ndfEnvironment)
      let password = generateSecret()
      try passwordStorage.save(password)
      try? fileManager.removeItem(atPath: directoryPath)
      try? fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
      return try newCMixFromBackup(
        ndfJSON: String(data: ndfData, encoding: .utf8)!,
        storageDir: directoryPath,
        backupPassphrase: passphrase,
        sessionPassword: password,
        backupFileContents: backup
      )
    }
  }
}

extension CMixManagerRestore {
  public static let unimplemented = CMixManagerRestore(
    run: XCTUnimplemented("\(Self.self)")
  )
}
