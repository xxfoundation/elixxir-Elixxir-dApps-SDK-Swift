import Foundation
import XCTestDynamicOverlay

public struct CMixManagerCreate {
  public var run: () throws -> CMix

  public func callAsFunction() throws -> CMix {
    try run()
  }
}

extension CMixManagerCreate {
  public static func live(
    environment: Environment,
    downloadNDF: DownloadAndVerifySignedNdf,
    generateSecret: GenerateSecret,
    passwordStorage: PasswordStorage,
    directoryPath: String,
    fileManager: FileManager,
    newCMix: NewCMix,
    getCMixParams: GetCMixParams,
    loadCMix: LoadCMix
  ) -> CMixManagerCreate {
    CMixManagerCreate {
      let ndfData = try downloadNDF(environment)
      let password = generateSecret()
      try passwordStorage.save(password)
      try? fileManager.removeItem(atPath: directoryPath)
      try? fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
      try newCMix(
        ndfJSON: String(data: ndfData, encoding: .utf8)!,
        storageDir: directoryPath,
        password: password,
        registrationCode: nil
      )
      return try loadCMix(
        storageDir: directoryPath,
        password: password,
        cMixParamsJSON: getCMixParams()
      )
    }
  }
}

extension CMixManagerCreate {
  public static let unimplemented = CMixManagerCreate(
    run: XCTUnimplemented("\(Self.self)")
  )
}
