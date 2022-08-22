import XXClient
import XCTestDynamicOverlay

public struct Create {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension Create {
  public static func live(_ env: Environment) -> Create {
    Create {
      let ndfData = try env.downloadNDF(env.ndfEnvironment)
      let password = env.generateSecret()
      try env.passwordStorage.save(password)
      let storageDir = env.storageDir
      try env.directoryManager.remove(storageDir)
      try env.directoryManager.create(storageDir)
      try env.newCMix(
        ndfJSON: String(data: ndfData, encoding: .utf8)!,
        storageDir: storageDir,
        password: password,
        registrationCode: nil
      )
    }
  }
}

extension Create {
  public static let unimplemented = Create(
    run: XCTUnimplemented()
  )
}
