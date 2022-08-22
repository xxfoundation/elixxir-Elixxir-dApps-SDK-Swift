import XXClient
import XCTestDynamicOverlay

public struct MessengerLoad {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension MessengerLoad {
  public static func live(_ env: MessengerEnvironment) -> MessengerLoad {
    MessengerLoad {
      env.ctx.cMix = try env.loadCMix(
        storageDir: env.storageDir(),
        password: try env.passwordStorage.load(),
        cMixParamsJSON: env.getCMixParams()
      )
    }
  }
}

extension MessengerLoad {
  public static let unimplemented = MessengerLoad(
    run: XCTUnimplemented()
  )
}
