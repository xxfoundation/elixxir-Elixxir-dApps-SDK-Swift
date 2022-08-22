import XXClient
import XCTestDynamicOverlay

public struct Load {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension Load {
  public static func live(_ env: Environment) -> Load {
    Load {
      env.cMix.set(try env.loadCMix(
        storageDir: env.storageDir,
        password: try env.passwordStorage.load(),
        cMixParamsJSON: env.getCMixParams()
      ))
    }
  }
}

extension Load {
  public static let unimplemented = Load(
    run: XCTUnimplemented()
  )
}
