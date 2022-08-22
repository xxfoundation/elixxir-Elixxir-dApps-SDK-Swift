import XXClient
import XCTestDynamicOverlay

public struct MessengerCreate {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension MessengerCreate {
  public static func live(_ env: MessengerEnvironment) -> MessengerCreate {
    MessengerCreate {
      let ndfData = try env.downloadNDF(env.ndfEnvironment)
      let password = env.generateSecret()
      try env.passwordStorage.save(password)
      let storageDir = env.storageDir
      try env.fileManager.removeDirectory(storageDir)
      try env.fileManager.createDirectory(storageDir)
      try env.newCMix(
        ndfJSON: String(data: ndfData, encoding: .utf8)!,
        storageDir: storageDir,
        password: password,
        registrationCode: nil
      )
    }
  }
}

extension MessengerCreate {
  public static let unimplemented = MessengerCreate(
    run: XCTUnimplemented()
  )
}
