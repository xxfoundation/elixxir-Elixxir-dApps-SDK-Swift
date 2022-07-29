import Foundation
import XCTestDynamicOverlay

public struct CmixManagerCreate {
  public var run: () throws -> Cmix

  public func callAsFunction() throws -> Cmix {
    try run()
  }
}

extension CmixManagerCreate {
  public static func live(
    environment: Environment,
    downloadNDF: DownloadAndVerifySignedNdf,
    generateSecret: GenerateSecret,
    passwordStorage: PasswordStorage,
    directoryPath: String,
    fileManager: FileManager,
    newCmix: NewCmix,
    getCmixParams: GetCmixParams,
    loadCmix: LoadCmix
  ) -> CmixManagerCreate {
    CmixManagerCreate {
      let ndfData = try downloadNDF(environment)
      let password = generateSecret()
      try passwordStorage.save(password)
      try? fileManager.removeItem(atPath: directoryPath)
      try? fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
      try newCmix(
        ndfJSON: String(data: ndfData, encoding: .utf8)!,
        storageDir: directoryPath,
        password: password,
        registrationCode: nil
      )
      return try loadCmix(
        storageDir: directoryPath,
        password: password,
        cmixParamsJSON: getCmixParams()
      )
    }
  }
}

extension CmixManagerCreate {
  public static let unimplemented = CmixManagerCreate(
    run: XCTUnimplemented("\(Self.self)")
  )
}
